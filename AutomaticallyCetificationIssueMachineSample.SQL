/* Copy Right 2020 Kentaro Kurose */


/* Sample script for Automated Certification Issue Machine in University */
/* Just a sample source and does'nt work by itself */
/* Dare to use magic number                         */

create or replace package XXXXX.acm

is

function init_pass(
    i_stu_idx in varchar2
) return varchar2;

procedure init_student(
    i_stu_cd in varchar2
   ,i_password in varchar2 default null 
   ,i_initpass in varchar2 default null 
);

procedure check_idcard(
     i_mode        in number    
    ,i_stu_cd      in varchar2  
    ,i_check_digit in varchar2  
    ,i_issue_cnt   in varchar2  
    ,i_expiry_date in varchar2  
                                
    ,r_ret         out varchar2 
    ,r_errmes      out varchar2 
    ,r_password    out varchar2 
    ,r_is_school   out varchar2 
    ,r_is_school_e  out varchar2
    ,r_is_due       out varchar2
    ,r_is_due_e     out varchar2
    ,r_is_results   out varchar2
    ,r_is_results_e out varchar2
    ,r_is_jr        out varchar2
    ,r_is_health    out varchar2
);

procedure pass_change(
    i_stu_cd in varchar2
   ,i_new_pass in varchar2
);

procedure lock_out(
    i_stu_cd in varchar2
);

procedure unlock(
    i_stu_cd in varchar2
);

function get_acm_pass
return varchar2;

function jr_expiry_date(
    i_date varchar2 default to_char(sysdate,'yyyy/mm/dd')
)
return varchar2;

function get_cert_times(
    i_id in varchar2
) return number;

function cert_count(
    i_cert_cd in varchar2
   ,i_stu_cd in varchar2
) return number;

function jr_count(
    i_cert_cd in varchar2
   ,i_stu_cd in varchar2
) return number;

function action_name(
    i_act_cd in number
) return varchar2;

procedure write_log(
    i_stu_cd      in varchar2 
   ,i_sim_cd      in varchar2 
   ,i_action_cd   in  number  
   ,i_action_err  in  varchar2
   ,i_cert_cd     in  varchar2
   ,i_cert_cnt    in  number  
);

function is_available(
    i_date varchar2 default to_char(sysdate,'yyyy/mm/dd')
) return varchar2;

function is_school(
     i_stu_idx  varchar2 
    ,i_fac_cd   varchar2 
    ,i_je   in number default 0 
) return varchar2;

function is_due(
     i_stu_idx  varchar2   
    ,i_fac_cd   varchar2   
    ,i_due_cd   varchar2   
    ,i_due_date varchar2   
    ,i_out_date varchar2   
    ,i_je   in number default 0 
) return varchar2;

function is_results(
     i_stu_idx varchar2  
    ,i_fac_cd  varchar2  
    ,i_grad_cd number    
    ,i_je   in number default 0 
) return varchar2;

function is_jr(
     i_stu_idx varchar2
    ,i_fac_cd  varchar2   
) return varchar2;

function is_health(
     i_stu_idx varchar2
    ,i_fac_cd  varchar2  
) return varchar2;

end;

/



create or replace package BODY XXXXX.acm
is

function init_pass(
    i_stu_idx in varchar2
) return varchar2
is
begin
    return acm_ex.init_pass(i_stu_idx);
end;

procedure init_student(
    i_stu_cd in varchar2
   ,i_password in varchar2 default null 
   ,i_initpass in varchar2 default null 
)
is
    cursor c_stu is
        select
             stu_idx
            ,stu_cd
        from student
            where stu_cd = i_stu_cd ;
    stu_rec c_stu%rowtype := null;

    cursor c_pass(i_stu_idx varchar2) is
        select * from student_pass
            where stu_idx = i_stu_idx ;
    pass_rec c_pass%rowtype := null;

    a_hit integer := null;

    a_encode_pass varchar2(136) := null;
    a_encode_init varchar2(136) := null;
begin
    open c_stu;
    fetch c_stu into stu_rec;
    if c_stu%found then a_hit := 1 ;
    else                a_hit := 0 ;
    end if;
    close c_stu;

    if a_hit = 0 then return;
    end if;

    open c_pass(stu_rec.stu_idx);
    fetch c_pass into pass_rec;
    if c_pass%found then a_hit := 1 ;
    else                 a_hit := 0 ;
    end if;
    close c_pass;

    if i_password > ' ' then
        a_encode_pass := crypt_lib.encode(i_password);
    end if;

    if i_initpass > ' ' then
        a_encode_init := crypt_lib.encode(i_initpass);
        update student set edit_dt=sysdate
            where stu_idx = stu_rec.stu_idx;
    end if;

    if a_hit = 0 then
        if a_encode_init is null then
            a_encode_init := crypt_lib.encode(init_pass(stu_rec.stu_idx));
        end if;
        if a_encode_pass is null then
            a_encode_pass := a_encode_init;
        end if;
        insert into student_pass(
             stu_idx          
            ,stu_cd           
            ,init_pass        
            ,password         
        ) values (
             stu_rec.stu_idx  
            ,stu_rec.stu_cd   
            ,a_encode_init    
            ,a_encode_pass    
        );
    else
        if stu_rec.stu_cd != pass_rec.stu_cd then
            update student_pass set stu_cd = stu_rec.stu_cd
                where stu_idx = stu_rec.stu_idx;
        end if;

        if i_password > ' ' then               
            update student_pass set
                password = a_encode_pass       
            where stu_idx = stu_rec.stu_idx;
        end if;
        if i_initpass > ' ' then               
            update student_pass set
                init_pass = a_encode_init      
            where stu_idx = stu_rec.stu_idx;
        end if;
    end if;
end;

function test_stu_cd
return varchar2
is
    cursor c1 is select key_value from system_ini
        where section='XXX' and entry='xxxxxx';
    a_value varchar2(40) := null;
begin
    open c1;
    fetch c1 into a_value;
    close c1;
    return a_value;
end;

function test_password
return varchar2
is
    cursor c1 is select key_value from system_ini
        where section='Acm' and entry='Test_password';
    a_value varchar2(40) := null;
begin
    open c1;
    fetch c1 into a_value;
    close c1;
    return a_value;
end;

function encode(
    i_pass varchar2
) return varchar2
is
    a_length number;
    a_code varchar2(40) := null;
    a number;

    a_ret varchar2(16000) := null;
begin
    if i_pass is null then return null;
    end if;

    a_length := length(i_pass);
    for i in 1..a_length loop
        a_code := str_lib.str_to_code( substr(i_pass, i, 1), 10);
        a := to_number(a_code) + a_length + i;
        a_ret := a_ret || trim(to_char(a, '099'));
    end loop;

    return a_ret;
end;

function to_edate(
    i_jdate varchar2
) return varchar2
is
    a_ini   varchar2(40);
    a_jdate varchar2(40);
begin
    if i_jdate is null then return null;
    end if;

    case substr(i_jdate,1,1)
    when '1' then a_ini := 'M';
    when '2' then a_ini := 'T';
    when '3' then a_ini := 'S';
    when '4' then a_ini := 'H';
    else          a_ini := 'X';
    end case;

    dbms_output.put_line('*1 —LŒøŠúŒÀ=' || i_jdate);

    a_jdate := substr(i_jdate,2,2)  || '/' || substr(i_jdate,4,2) || '/' || substr(i_jdate,6,2);

    return date_lib.to_edate(a_ini, a_jdate);
end;

procedure check_idcard(
     i_mode        in number       
    ,i_stu_cd      in varchar2     
    ,i_check_digit in varchar2     
    ,i_issue_cnt   in varchar2     
    ,i_expiry_date in varchar2     
                                   
    ,r_ret         out varchar2    
    ,r_errmes      out varchar2    
    ,r_password    out varchar2    
    ,r_is_school   out varchar2    
    ,r_is_school_e  out varchar2   
    ,r_is_due       out varchar2   
    ,r_is_due_e     out varchar2   
    ,r_is_results   out varchar2   
    ,r_is_results_e out varchar2   
    ,r_is_jr        out varchar2   
    ,r_is_health    out varchar2   
)
is
    cursor c_pass is
        select
             stu_div_cd
            ,regular_cd
            ,nvl(issue_cnt,0) issue_cnt
            ,expiry_date
            ,lock_out_dt
            ,out_date
            ,crypt_lib.decode(password) password
            ,acm.is_school(stu_idx, fac_cd,0) is_school                 
            ,acm.is_school(stu_idx, fac_cd,1) is_school_e               
            ,acm.is_due(stu_idx, fac_cd, due_cd, due_date, out_date,0) is_due   
            ,acm.is_due(stu_idx, fac_cd, due_cd, due_date, out_date,1) is_due_e 
            ,acm.is_results(stu_idx, fac_cd, grad_cd,0) is_results      
            ,acm.is_results(stu_idx, fac_cd, grad_cd,1) is_results_e    
            ,acm.is_jr(stu_idx, fac_cd) is_jr                           
            ,acm.is_health(stu_idx, fac_cd) is_health                   
            ,adr                       
            ,tel                       
        from student_pass_list
            where stu_cd = i_stu_cd ;
    pass_rec c_pass%rowtype;

    a_hit integer := null ;

    a_expiry_date varchar2(40);
    a_era varchar2(40);
begin
    if i_stu_cd = test_stu_cd then
        r_ret := 'TEST';
        r_errmes := null;
        r_password := encode(test_password);
        return;
    end if;

    init_student(i_stu_cd);

    open c_pass;
    fetch c_pass into pass_rec;
    if c_pass%found then a_hit := 1 ;
    else                 a_hit := 0 ;
    end if;
    close c_pass;
    a_expiry_date := date_lib.to_date_fmt(i_expiry_date);
    r_errmes := null;

    case
    when a_hit = 0                             then r_errmes := 'Not hit';
    when pass_rec.regular_cd != '1'            then r_errmes := 'Non regular';
    when sysdate - pass_rec.lock_out_dt < 1/24 then r_errmes := 'Locked';
    when pass_rec.expiry_date is null          then r_errmes := 'Invalid(expire date)';
    when to_char(sysdate,'yyyy/mm/dd') > a_expiry_date and a_expiry_date > ' ' and i_mode = 0
                                               then r_errmes := 'Expired';
    when to_char(sysdate,'yyyy/mm/dd') > date_lib.get_last_date(pass_rec.expiry_date)
                                               then r_errmes := 'Expired';
    when to_char(sysdate,'yyyy/mm/dd') > date_lib.get_last_date(pass_rec.out_date) and pass_rec.out_date > ' '
                                               then r_errmes := 'Already graduated';
    when pass_rec.password is null
                                               then r_errmes := 'Need passcord';
    when pass_rec.adr is null or pass_rec.tel is null
                                               then r_errmes := 'Need registration';
    else null;
    end case;

    if r_errmes is null then r_ret := 'OK';
    else                     r_ret := 'NG';
    end if;

    r_password := encode(pass_rec.password);

    r_is_school   := pass_rec.is_school;      
    r_is_school_e := pass_rec.is_school_e;    
    r_is_due      := pass_rec.is_due;         
    r_is_due_e    := pass_rec.is_due_e;       
    r_is_results  := pass_rec.is_results;     
    r_is_results_e:= pass_rec.is_results_e;   
    r_is_jr       := pass_rec.is_jr;          
    r_is_health   := pass_rec.is_health;      
end;

procedure pass_change(
    i_stu_cd in varchar2
   ,i_new_pass in varchar2
)
is
begin
    update student_pass set
        password = crypt_lib.encode(i_new_pass)
       ,change_dt = sysdate
    where stu_cd = i_stu_cd;
end;

procedure lock_out(
    i_stu_cd in varchar2
)
is
begin
    update student_pass set
        lock_out_dt = sysdate
    where stu_cd = i_stu_cd;
end;

procedure unlock(
    i_stu_cd in varchar2
)
is
begin
    update student_pass set
        lock_out_dt = null
    where stu_cd = i_stu_cd;
end;

function get_acm_pass
return varchar2
is
    cursor c1 is select key_value from system_ini
        where section='XXX' and entry='xxxxx';
    a_value varchar2(40) := null;
begin
    open c1;
    fetch c1 into a_value;
    close c1;
    return encode(a_value);
end;

function jr_expiry_date(
    i_date varchar2 default to_char(sysdate,'yyyy/mm/dd')
)
return varchar2
is
begin
    return jr_lib.jr_expiry_date(i_date);
end;

function get_cert_times(
    i_id in varchar2
) return number
is
    cursor c1 is select key_value from system_ini
        where section='Acm' and entry=i_id;
    a_value varchar2(40) := null;
begin
    open c1;
    fetch c1 into a_value;
    close c1;

    return to_number(a_value);
end;

function cert_count(
     i_cert_cd in varchar2
    ,i_stu_cd in varchar2
) return number
is

    cursor c_log is
        select count(*) cnt from cert_log
        where stu_cd=i_stu_cd
            and cert_cd=i_cert_cd
            and cert_date = to_char(sysdate,'yyyy/mm/dd')
            and invalid is null;
    a_limit number;
    a_entry varchar2(80);
    a_cnt number;
    r_cnt number;
begin

    open c_log;
    fetch c_log into a_cnt;
    close c_log;

    a_limit := acm.get_cert_times(i_cert_cd);

    if a_cnt < a_limit then r_cnt := a_limit-a_cnt;
    else                    r_cnt := 0;
    end if;

    return r_cnt;
end;

function jr_count(
    i_cert_cd in varchar2
   ,i_stu_cd in varchar2
) return number
is
    cursor c_stu is select * from student where stu_cd=i_stu_cd;
    stu_rec c_stu%rowtype;

    cursor c_log(i_stu_idx varchar2) is select count(*) cnt from cert_log
        where stu_idx=i_stu_idx
            and cert_cd=i_cert_cd
            and cert_date between basic.str_date(0,0) and basic.end_date(0,0)
            and invalid is null;
    a_limit number;
    a_cnt number;
    r_cnt number;
begin
    open c_stu;
    fetch c_stu into stu_rec;
    close c_stu;

    open c_log(stu_rec.stu_idx);
    fetch c_log into a_cnt;
    close c_log;

    a_limit := acm.get_cert_times(i_cert_cd);

    if a_cnt < a_limit then r_cnt := a_limit-a_cnt;
    else                    r_cnt := 0;
    end if;

    return r_cnt;
end;

function action_name(
    i_act_cd in number
) return varchar2
is
    name varchar2(400):=null;
    a_act_cd number;
begin
    a_act_cd := i_act_cd;
    case a_act_cd
        when  1 then name := 'logon';
        when  2 then name := 'logout';             
        when  3 then name := 'cancel';             
        when  9 then name := 'timeout';
        when 11 then name := 'enter passcode';
        when 21 then name := 'change passcode(enter)';
        when 22 then name := 'change passcode(confirm)';
        when 23 then name := 'change passcode(re-enter)';
        when 31 then name := 'pront';
        else         name := null ;
    end case;
    return name;
end;

procedure write_log(
    i_stu_cd      in varchar2  
   ,i_sim_cd      in varchar2  
   ,i_action_cd   in  number   
   ,i_action_err  in  varchar2 
   ,i_cert_cd     in  varchar2 
   ,i_cert_cnt    in  number   
)
is
    cursor c_stu is select
            stu_idx
            ,name
        from student
            where stu_cd = i_stu_cd ;
    stu_rec c_stu%rowtype := null;
begin

    open c_stu;
    fetch c_stu into stu_rec;
    close c_stu;

    insert into acm_log (
        stu_idx              
        ,stu_cd              
        ,stu_name            
        ,sim_cd              
        ,action_cd           
        ,action_dt           
        ,action_err          
        ,cert_cd             
        ,cert_cnt            
        ,user_name           
        ,host_name           
        ,ip_address          
    ) values (
        stu_rec.stu_idx      
        ,i_stu_cd            
        ,stu_rec.name        
        ,i_sim_cd            
        ,i_action_cd         
        ,sysdate             
        ,i_action_err        
        ,i_cert_cd           
        ,i_cert_cnt          
        ,user                              
        ,log_lib.log_info('terminal'  ,24) 
        ,log_lib.log_info('ip_address',15) 
    );
end;

function is_available(
    i_date varchar2 default to_char(sysdate,'yyyy/mm/dd')
) return varchar2
is
    cursor c1 is select rowid from acm_holiday
         where i_date=holiday_lib.get_holiday(type_cd, month, day, week)
             and month=to_number( substr(i_date,6,2) );

    cursor c2 is select rowid from acm_off_date
         where i_date between date_str and date_end;

    a_rowid urowid;
begin

    if to_char( to_date(i_date,'yyyy/mm/dd'), 'd') in ('1') then       --SundayiNot includes Saturdayj
        return 'NO';
    end if;

    open c1;
    fetch c1 into a_rowid;
    if c1%found then
        close c1;
        return 'NO';
    end if;
    close c1;

    open c2;
    fetch c2 into a_rowid;
    if c2%found then
        close c2;
        return 'NO';
    end if;
    close c2;

    return 'YES';
end;

function is_school(
     i_stu_idx  varchar2  
    ,i_fac_cd   varchar2  
    ,i_je   in number default 0 
) return varchar2
is
    a_ret varchar2(40);
begin
    a_ret := acm_halt.is_halt('SCHOOL', i_fac_cd, i_stu_idx, i_je);

    if a_ret = 'YES' then
        if stu_lib.is_absent(i_stu_idx, to_char(sysdate,'yyyy/mm/dd')) = 1 then
            a_ret := 'NO';
        end if;

        if stu_lib.is_suspension(i_stu_idx, to_char(sysdate,'yyyy/mm/dd')) = 1 then
            a_ret := 'NO';
        end if;
    end if;

    return a_ret;
end;

function is_due(
     i_stu_idx  varchar2   
    ,i_fac_cd   varchar2   
    ,i_due_cd   varchar2   
    ,i_due_date varchar2   
    ,i_out_date varchar2   
    ,i_je   in number default 0
) return varchar2
is
    a_ret varchar2(40);
begin
    a_ret := acm_halt.is_halt('DUE', i_fac_cd, i_stu_idx, i_je);

    if a_ret = 'YES' then
        if i_due_cd = '1' then a_ret := 'YES';
        else                   a_ret := 'NO';
        end if;
        if i_out_date > ' ' then
            if to_char(sysdate,'yyyy/mm/dd') >= i_out_date then
                a_ret := 'NO';
            end if;
        end if;
    end if;

    return a_ret;
end;

function is_results(
     i_stu_idx varchar2   
    ,i_fac_cd  varchar2   
    ,i_grad_cd number     
    ,i_je   in number default 0
) return varchar2
is
    cursor c1 is
        select rowid
            from results_term
        where fac_cd=i_fac_cd
            and data_cd='1'        
            and grad_cd=i_grad_cd
            and acm_cd=1           
            and open_cd='1'        
    ;
    a_rowid urowid;
    a_ret varchar2(40);
begin
    a_ret := acm_halt.is_halt('RESULTS', i_fac_cd, i_stu_idx, i_je);

    if a_ret = 'YES' then
        open c1;
        fetch c1 into a_rowid;
        if c1%found then a_ret := 'YES';
        else             a_ret := 'NO' ;
        end if;
        close c1;
    end if;

    return a_ret;
end;

function is_jr(
     i_stu_idx varchar2
    ,i_fac_cd  varchar2    
) return varchar2
is
    a_ret varchar2(40);
begin
    a_ret := acm_halt.is_halt('JR', i_fac_cd, i_stu_idx, 0);

    return a_ret;
end;

function is_health(
     i_stu_idx varchar2
    ,i_fac_cd  varchar2   
) return varchar2
is
    cursor c1 is select issue_cd from student_health where stu_idx=i_stu_idx;
    a_issue_cd varchar2(4) := null;
    a_ret      varchar2(40);
begin
    a_ret := acm_halt.is_halt('HEALTH', i_fac_cd, i_stu_idx, 0);

    if a_ret = 'YES' then
        open c1;
        fetch c1 into a_issue_cd;
        close c1;

        if a_issue_cd = '0' then a_ret := 'YES';
        else                     a_ret := 'NO' ;
        end if;
    end if;

    return a_ret;
end;

end;

/
