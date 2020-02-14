/* Copy Right 2020 Kentaro Kurose */


/* Sample script for Course Numbering in University */
/* Just a sample source and does'nt work by itself  */
/* Dare to use magic number                         */

create or replace package XXXXX.numbering_lib

is

function enter_term(
    i_enter_date in varchar2
) return varchar2;

function enter_div(
     i_enter_year in varchar2
    ,i_cur_year   in varchar2
    ,i_enter_cd   in varchar2   
    ,i_sub_cd     in varchar2   
) return varchar2;

function other(
    i_abroad_cd in varchar2
    ,i_exchange_cd in varchar2
) return varchar2;

function abroad_div(
    i_abroad_cd in varchar2
) return varchar2;

function get_stu_fmt(
     i_stu_fmt  in varchar2  
    ,i_cur_year in varchar2  
    ,i_mode     in integer default 0 
) return varchar2;

function get_stu_cd(
     num_rec      in numbering%rowtype
    ,i_regular_cd in varchar2
    ,i_cur_year   in varchar2
) return varchar2;

procedure numbering_start(
    i_regular_cd in varchar2
   ,i_year       in varchar2
   ,i_enter_date in varchar2
   ,num_rec      in numbering%rowtype
   ,i_mode       in integer
);

procedure set_stu_cd(
    i_regular_cd in varchar2
   ,i_year       in varchar2
   ,i_enter_date in varchar2
   ,i_fac_min    in varchar2
   ,i_fac_max    in varchar2
   ,i_mode       in integer
);

end;

/


create or replace package BODY XXXXX.numbering_lib
is

    g_cnt number := 0;

function enter_term(
    i_enter_date in varchar2
) return varchar2
is
   a_mm   varchar2(8);
   r_code varchar2(4):=null;
begin
    a_mm := substrb(i_enter_date,6,2);
    if a_mm between '04' and '09' then r_code:='1' ;  
    else                               r_code:='2' ;  
    end if;
    return r_code;
end;

function enter_div(
     i_enter_year in varchar2
    ,i_cur_year   in varchar2
    ,i_enter_cd   in varchar2   
    ,i_sub_cd     in varchar2   
) return varchar2
is
   r_code varchar2(4):=null;
begin
    case
    when i_sub_cd = '50'   then r_code:='3';     
    when i_enter_cd = '04' then r_code:='4';     
    when i_enter_cd = '05' then r_code:='5';     
    when i_enter_year = i_cur_year then r_code:='1';    
    else                                r_code:='2';    
    end case;
    return r_code;
end;

function other(
    i_abroad_cd in varchar2
    ,i_exchange_cd in varchar2
) return varchar2
is
   r_code varchar2(4):=null;
begin
    if i_abroad_cd > ' ' then
        if i_exchange_cd > ' ' then r_code := '2';   
        else                        r_code := '1';   
        end if;
    else                            r_code := '1';   
    end if;
    return r_code;
end;

function abroad_div(
    i_abroad_cd in varchar2
) return varchar2
is
   r_code varchar2(4):=null;
begin
   if i_abroad_cd >' ' then r_code:='1';        
   else                     r_code:='0';        
   end if;
   return r_code;
end;

function get_stu_fmt(
     i_stu_fmt  in varchar2  
    ,i_cur_year in varchar2  
    ,i_mode     in integer default 0 
) return varchar2
is
    a_yy      varchar2(40) := null;
    a_stu_fmt varchar2(40) := null;
    r_value   varchar2(40) := null;
    a_str_len integer;
begin
    a_stu_fmt := replace(i_stu_fmt,'n','');
    case i_mode
    when 0 then
        a_yy := substrb(i_cur_year, 3, 2);
        r_value := replace(a_stu_fmt, 'yy', a_yy);
    when 1 then
        r_value := replace(i_stu_fmt, a_stu_fmt, '');
        a_str_len := lengthb(r_value);

        if a_str_len>1 then r_value := rpad('0',a_str_len,'9');
        else                r_value := '9';
        end if;
        r_value := 'fm' || r_value;
    else null;
    end case;
    return r_value;
end;

function get_stu_cd(
     num_rec      in numbering%rowtype
    ,i_regular_cd in varchar2
    ,i_cur_year   in varchar2
) return varchar2

is
    cursor c1(i_stu_fmt varchar2, i_no_pos integer, i_no_len integer, i_min integer, i_max integer) is
        select nvl(max(no),0) from (
            select substrb(stu_cd,i_no_pos,i_no_len) no
            from student where regular_cd=i_regular_cd and stu_cd like i_stu_fmt || '%'
            union all
            select substrb(stu_cd,i_no_pos,i_no_len) no
            from past_student where regular_cd=i_regular_cd and stu_cd like i_stu_fmt || '%'
            union all
            select substrb(stu_cd,i_no_pos,i_no_len) no
            from enroll where regular_cd=i_regular_cd and stu_cd like i_stu_fmt || '%'
        ) where no between i_min and i_max ;

    a_str_fmt varchar2(40):=null;
    a_no_fmt  varchar2(40):=null;
    a_min     integer;
    a_max     integer;
    a_str_pos integer;
    a_str_len integer;
    a_err_no  number;
    a_emes    varchar2(400):=null;
    a_no      integer;
    a_value   varchar2(80):=null;
    r_stu_cd  varchar2(80):= null;
begin
    a_str_fmt := get_stu_fmt(num_rec.stu_format, i_cur_year,0);     
    a_no_fmt  := get_stu_fmt(num_rec.stu_format, i_cur_year,1);     

    a_min := num_rec.str_no;
    a_max := num_rec.end_no;
    a_str_pos := nvl(lengthb(a_str_fmt),0)+1;
    a_value := replace(a_no_fmt, 'fm', '');
    a_str_len := nvl(lengthb(a_value),0);

    if    a_min<1 or a_min>a_max then a_err_no:=-20001 ;          
    elsif a_str_len<2 then            a_err_no:=-20002 ;          
    end if;

    if a_err_no is not null then
        a_emes:='Err:' || num_rec.fac_cd || 'Šw‰È=' || num_rec.dpt_cd;
        raise_application_error(a_err_no, a_emes);
    end if;

    open c1(a_str_fmt, a_str_pos, a_str_len, a_min, a_max);
    fetch c1 into a_no;
    close c1;

    if a_no < a_min then a_no := a_min ;
    else                 a_no := a_no + 1 ;
    end if;

    if    a_no < a_min then a_err_no:=-20001 ;     
    elsif a_no > a_max then a_err_no:=-20001 ;     
    end if;
    if a_err_no is not null then
        a_err_no:=-20001 ;
        a_emes:='Err:'   || num_rec.fac_cd
                                             || 'Faculty='   || num_rec.dpt_cd
                                             || 'Course=' || num_rec.div_cd;
        raise_application_error(a_err_no, a_emes);
    end if;

    r_stu_cd := a_str_fmt || to_char(a_no,a_no_fmt);
    r_stu_cd := r_stu_cd || ehime_lib.check_digit(r_stu_cd);    
    return r_stu_cd;
end;

procedure numbering_start(
    i_regular_cd in varchar2
   ,i_year       in varchar2
   ,i_enter_date in varchar2
   ,num_rec      in numbering%rowtype
   ,i_mode       in integer
)
is
    cursor c0 is select distinct cur_year from enroll
            where (
               i_year is null or cur_year = i_year
            )
            and (
               i_enter_date is null or enter_date <= i_enter_date
            )
            and regular_cd=i_regular_cd
            and fac_cd = num_rec.fac_cd
            and dpt_cd = num_rec.dpt_cd
            and ( div_cd = num_rec.div_cd or num_rec.div_cd is null )
            and ( num_rec.enter_term_cd='0' or num_rec.enter_term_cd=numbering_lib.enter_term(enter_date) ) 
                                                                                                            
            and ( num_rec.enter_div_cd='0' or num_rec.enter_div_cd=numbering_lib.enter_div(enter_year, cur_year, enter_cd, enter_sub) )
            and num_rec.other_cd=numbering_lib.other(abroad_cd,exchange_cd)
            and out_cd is null
        order by cur_year ;

    type c1_type is ref cursor;
    c1 c1_type;

    a_do         integer;
    a_stu_cd     varchar2(40):=null;
    a_fac_cd     varchar2(16) :=null;
    a_sql        varchar2(16000);
    a_order      varchar2(800);

    type a_rec_type is record(
         rowid urowid
         ,stu_cd varchar2(80)
    );
    c1_rec a_rec_type;
begin

    a_order := ' order by fac_cd, dpt_cd, ';

    case num_rec.order_cd
    when '1' then a_order := a_order || ' div_cd nulls last, ';
    when '3' then a_order := a_order || ' div_cd nulls last, ';
    else null;
    end case;

    if num_rec.order_cd in ('0','1') then
         a_order := a_order || ' numbering_lib.abroad_div(abroad_cd), ';
    end if;

    a_order := a_order || ' kana_lib.ja_sort(kana,2) ';

    for c0_rec in c0 loop
        g_cnt := g_cnt + 1;
        a_sql := ' select rowid, stu_cd from enroll where ';
        a_sql := a_sql || ' regular_cd=''' || i_regular_cd   || ''' ';
        a_sql := a_sql || ' and fac_cd=''' || num_rec.fac_cd || ''' ';
        a_sql := a_sql || ' and dpt_cd=''' || num_rec.dpt_cd || ''' ';
        if num_rec.div_cd > ' ' then
            a_sql := a_sql || ' and div_cd=''' || num_rec.div_cd || ''' ';
        end if;

        if num_rec.enter_term_cd > '0' then
            a_sql := a_sql || ' and numbering_lib.enter_term(enter_date)=''' || num_rec.enter_term_cd || ''' ';
        end if;

        if num_rec.enter_div_cd > '0' then
            a_sql := a_sql || ' and numbering_lib.enter_div(enter_year,cur_year, enter_cd, enter_sub)='''
                    || num_rec.enter_div_cd || ''' ';
        end if;

        a_sql := a_sql || ' and numbering_lib.other(abroad_cd,exchange_cd)=''' || num_rec.other_cd || ''' ';

        a_sql := a_sql || ' and out_cd is null ';
        a_sql := a_sql || ' and cur_year=''' || c0_rec.cur_year || ''' ';

        if i_enter_date > ' ' then
            a_sql := a_sql || ' and enter_date <=''' || i_enter_date || ''' ';
        end if;

        a_sql := a_sql || a_order;

        insert into tmp_trace (sql_str, sql_dt, dno) values ( a_sql, sysdate, g_cnt);

        open c1 for a_sql;
        loop
            fetch c1 into c1_rec;
            exit when c1%notfound;

            if    i_mode=0 then a_do := 1;
            elsif i_mode=1 then
                if c1_rec.stu_cd > ' ' then a_do := 0; 
                else                        a_do := 1;
                end if;
            end if;

            if a_do = 1 then
                a_stu_cd := get_stu_cd(num_rec,i_regular_cd,c0_rec.cur_year);
                a_fac_cd := num_rec.fac_cd;
                update enroll set
                        stu_cd    = a_stu_cd
                       ,fee_no    = fee_lib.get_fee_no(a_stu_cd)
                       ,lib_no    = lib_lib.get_lib_no(a_fac_cd,a_stu_cd)
                       ,idcard_no = idcard_lib.get_idcard_no(a_stu_cd)
                    where rowid=c1_rec.rowid;
            end if;
        end loop;
        close c1;
    end loop;

end;

procedure set_stu_cd(
    i_regular_cd in varchar2
   ,i_year       in varchar2
   ,i_enter_date in varchar2
   ,i_fac_min    in varchar2
   ,i_fac_max    in varchar2
   ,i_mode       in integer
)
is
    cursor c0 is select stu_cd from enroll
        where (
           i_year is null or cur_year = i_year
        )
        and (
           i_enter_date is null or enter_date <= i_enter_date
        )
        and regular_cd=i_regular_cd
        and fac_cd between i_fac_min and i_fac_max for update ;

    cursor c1 is select * from numbering
        where fac_cd between i_fac_min and i_fac_max
        order by fac_cd, dpt_cd, div_cd, enter_term_cd, enter_div_cd, other_cd ;

begin
    if i_mode=0 then
        for c0_rec in c0 loop
            if c0_rec.stu_cd > ' ' then
--              update enroll set stu_cd = null where current of c0 ;
                update enroll set
                         stu_cd = null
                        ,fee_no = null
                        ,lib_no = null
                        ,idcard_no = null
                    where current of c0 ;
            end if;
        end loop;
    end if;

   for c1_rec in c1 loop
       numbering_start(
            i_regular_cd
           ,i_year
           ,i_enter_date
           ,c1_rec
           ,i_mode
       );
   end loop;
end;

end;

/
