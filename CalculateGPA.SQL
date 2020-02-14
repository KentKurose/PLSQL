/* Copy Right 2020 Kentaro Kurose */

/* Sample script for Calculatoin of GPA in University */
/* Just a sample source and does'nt work by itself */
/* Dare to use magic number                         */

create or replace package XXXXX.gp_lib

is
function get_gp(
    i_fac_cd    in varchar2  
   ,i_cur_year  in varchar2  
   ,i_result_cd in varchar2  
   ,i_score     in number    
   ,i_stu_idx   in varchar2 default null 
   ,i_status_cd in varchar2 default null 
   ,i_gpa_cd    in varchar2 default null 
) return number;

function is_gpa(
    i_stu_idx varchar2   
   ,i_year varchar2      
   ,i_enter_cd varchar2  
   ,i_fac_cd varchar2    
   ,i_dpt_cd varchar2    
   ,i_div_cd varchar2    
   ,i_lab_cd varchar2    
   ,i_sbj_cd varchar2    
   ,i_take_year varchar2 default null  
   ,i_take_term varchar2 default null  
) return number;          

function is_gpa_sbj_div(
    i_course_cd  in varchar2  
   ,i_sbj_div_cd in varchar2  
) return number;            

function gpa_note(
    i_stu_idx varchar2      
   ,i_sbj_cd varchar2       
   ,i_take_year varchar2    
   ,i_take_term varchar2    
) return varchar2;

function gpa_credits(
    i_credits   in number     
   ,i_range_cd  in varchar2   
   ,i_stu_idx   in varchar2   
   ,i_term_cd   in varchar2   
) return number;

function is_gpa_ex(
    i_stu_idx   varchar2    
   ,i_sbj_cd    varchar2    
   ,i_take_year varchar2    
   ,i_take_term varchar2    
) return number;            

function is_gpa_rec(
    i_stu_idx    varchar2   
   ,i_general_cd varchar2   
   ,i_course_cd  varchar2   
   ,i_sbj_cd     varchar2   
) return number ;           

end;


/

create or replace package body XXXXX.gp_lib
is

    type gp_rec is record( 
         gp number        
        ,expiry_dt date   
    ); 
    type t_elm      is table of gp_rec index by varchar2(4); 
    type t_gp_table is table of t_elm  index by varchar2(10);
    g_gp_table t_gp_table;         
    g_gp_table_dt date := null;    

function get_cash_gp(
    i_fac_cd    in varchar2 
   ,i_cur_year  in varchar2 
   ,i_result_cd in varchar2 
) return number
is
    cursor c2(i_basis_cd number) is
        select gp from result_table
            where basis_cd=i_basis_cd and result_cd=i_result_cd ;
    c2_rec c2%rowtype := null ;
    a_basis_cd number := null ;

    a_idx varchar2(10);
    a_gp number := null;
begin
    if i_fac_cd is null then
        return null;
    end if;
    if i_cur_year is null then
        return null;
    end if;
    if i_result_cd is null then
        return null;
    end if;

    a_idx := i_cur_year || '-' || i_fac_cd;

    if g_gp_table.exists(a_idx) then                   
        if g_gp_table(a_idx).exists(i_result_cd) then  
            if sysdate < g_gp_table(a_idx)(i_result_cd).expiry_dt then 
                                                                       
                return g_gp_table(a_idx)(i_result_cd).gp;
            end if;
        end if;
    end if;

    a_basis_cd := grade.get_basis_cd(i_fac_cd, i_cur_year);
    open c2(a_basis_cd);
    fetch c2 into a_gp;
    close c2;

    -- Set Cache
    g_gp_table(a_idx)(i_result_cd).gp        := a_gp ;
    g_gp_table(a_idx)(i_result_cd).expiry_dt := sysdate + 1/24/4   ; 

    return a_gp;
end;

function get_gp(
    i_fac_cd    in varchar2 
   ,i_cur_year  in varchar2 
   ,i_result_cd in varchar2 
   ,i_score     in number   
   ,i_stu_idx   in varchar2 default null 
   ,i_status_cd in varchar2 default null 
   ,i_gpa_cd    in varchar2 default null 
) return number
is
    a_gp number := null;
begin
    if i_status_cd in ('1','5') then   --‡ŠiE•s‡Ši
        a_gp := get_cash_gp(i_fac_cd, i_cur_year, i_result_cd);
    end if;
    return a_gp;
end;

function is_gpa(
    i_stu_idx varchar2     
   ,i_year varchar2        
   ,i_enter_cd varchar2    
   ,i_fac_cd varchar2      
   ,i_dpt_cd varchar2      
   ,i_div_cd varchar2      
   ,i_lab_cd varchar2      
   ,i_sbj_cd varchar2      
   ,i_take_year varchar2 default null  
   ,i_take_term varchar2 default null  
) return number          
is
    cursor c_cur is
        select rowid
            from course_rec
            where course_cd = course_rec_lib.get_cd(i_year, i_fac_cd, i_dpt_cd, i_div_cd, i_lab_cd)
                and sbj_cd = i_sbj_cd
                and gpa_exclude_cd = '1';   --exclude from GPA
    cur_rec c_cur%rowtype := null;
    a_is_gpa number := null;
begin
    a_is_gpa := 1;   

    open c_cur;
    fetch c_cur into cur_rec;
    if c_cur%found then
        a_is_gpa := 0; 
    end if;
    close c_cur;

    return a_is_gpa;
end;

function is_gpa_sbj_div(
    i_course_cd  in varchar2
   ,i_sbj_div_cd in varchar2
) return number             
is
    cursor c_cur is
        select gpa_exclude_cd
            from course_rec
            where course_cd = i_course_cd
                and sbj_cd_idx='*'       
                and sbj_div_cd like substr(i_sbj_div_cd,1,1) || '%'
                and req_ttl.is_include(i_sbj_div_cd, sbj_div_cd)=1
                and gpa_exclude_cd = '1' 
                and rownum=1;
    cur_rec c_cur%rowtype := null;
    a_is_gpa number := null;
begin
    a_is_gpa := 1;

    open c_cur;
    fetch c_cur into cur_rec;
    if c_cur%found then
        a_is_gpa := 0;
    end if;
    close c_cur;

    return a_is_gpa;
end;

function gpa_note(
    i_stu_idx varchar2     
   ,i_sbj_cd varchar2      
   ,i_take_year varchar2   
   ,i_take_term varchar2   
) return varchar2
is
    a_note varchar2(200) := null;
begin
    return a_note;
end;

function gpa_credits(
    i_credits   in number    
   ,i_range_cd  in varchar2  
   ,i_stu_idx   in varchar2  
   ,i_term_cd   in varchar2  
) return number
is
begin
    return i_credits;
end;

function is_gpa_ex(
    i_stu_idx   varchar2  
   ,i_sbj_cd    varchar2  
   ,i_take_year varchar2  
   ,i_take_term varchar2  
) return number           
is
     cursor c_stu is
         select
             cur_year   
            ,enter_cd   
            ,fac_cd     
            ,dpt_cd     
            ,div_cd     
           ,lab_cd      
         from student
         where stu_idx=i_stu_idx
         union all
         select
             cur_year    
            ,enter_cd    
            ,fac_cd      
            ,dpt_cd      
            ,div_cd      
            ,lab_cd      
         from past_student
         where stu_idx=i_stu_idx;
    stu_rec c_stu%rowtype;
begin
    open c_stu;
    fetch c_stu into stu_rec;
    close c_stu;
    return is_gpa(
         i_stu_idx           
        ,stu_rec.cur_year    
        ,stu_rec.enter_cd    
        ,stu_rec.fac_cd      
        ,stu_rec.dpt_cd      
        ,stu_rec.div_cd      
        ,stu_rec.lab_cd      
        ,i_sbj_cd            
        ,i_take_year         
        ,i_take_term         
    );
end;

function is_gpa_sbj(
    i_course_cd varchar2   
   ,i_sbj_cd    varchar2   
) return number            
is
    cursor c_cur is
        select rowid
            from course_rec
            where course_cd = i_course_cd
                and sbj_cd = i_sbj_cd
                and gpa_exclude_cd = '1';  
    cur_rec c_cur%rowtype := null;
    a_is_gpa number := null;
begin
    a_is_gpa := 1;  

    open c_cur;
    fetch c_cur into cur_rec;
    if c_cur%found then
        a_is_gpa := 0; 
    end if;
    close c_cur;

    return a_is_gpa;
end;

function is_gpa_rec(
    i_stu_idx    varchar2 
   ,i_general_cd varchar2 
   ,i_course_cd  varchar2 
   ,i_sbj_cd     varchar2 
) return number           
is
    a_is_gpa number := null;
begin
    a_is_gpa := 1;   

    case
    when is_gpa_sbj(i_course_cd , i_sbj_cd) = 0 then a_is_gpa := 0;
    when is_gpa_sbj(i_general_cd, i_sbj_cd) = 0 then a_is_gpa := 0;
    else null;
    end case;

    return a_is_gpa;
end;

end;


/
