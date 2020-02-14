/* Copy Right 2020 Kentaro Kurose */

/* Sample script for Studying Abroad Student in University */
/* Just a sample source and does'nt work by itself         */
/* Dare to use magic number                                */


create or replace TRIGGER "XXXXX".student_trigger
before delete or insert or update on student
for each row
declare
    a_stu_idx   varchar2(10) := null;
    a_stu_cd    varchar2(10) := null;
    a_stu_name  varchar2(200) := null;
    a_edit_mode varchar2(1) := null;
    a_edit_div  varchar2(1) := null;

    log_rec log_student_col%rowtype;
begin
    if inserting or updating then

        edit_lib.edit_info(
            inserting
           ,updating
           ,:new.register_dt
           ,:new.register_user
           ,:new.edit_dt
           ,:new.edit_user
        );
    end if;

    case
        when inserting then   
            a_stu_idx := :new.stu_idx; 
            a_stu_cd  := :new.stu_cd ; 
            a_stu_name:= :new.name   ; 
            a_edit_mode := '1';
            a_edit_div := '1';   
        when updating then       
            a_stu_idx := :old.stu_idx; 
            a_stu_cd  := :old.stu_cd ; 
            a_stu_name:= :old.name   ; 
            a_edit_mode := '2';
            if    :new.stu_cd != :old.stu_cd 
               or :new.name   != :old.name   
            then a_edit_div := '1';
            else a_edit_div := '2';
            end if;
        when deleting then       
            a_stu_idx := :old.stu_idx; 
            a_stu_cd  := :old.stu_cd ; 
            a_stu_name:= :old.name   ; 
            a_edit_mode := '3';
    end case;

    log_rec := null;
    log_rec.stu_idx     := a_stu_idx  ;
    log_rec.stu_cd      := a_stu_cd   ;
    log_rec.stu_name    := a_stu_name ;
    log_rec.data_area   := '0'        ;
    log_rec.user_name   := user       ;                        
    log_rec.os_user     := log_lib.log_info('os_user'   ,24);  
    log_rec.machine_name:= log_lib.log_info('terminal'  ,24);  
    log_rec.ip_address  := log_lib.log_info('ip_address',15);  
    log_rec.edit_dt     := sysdate    ;
    log_rec.edit_mode   := a_edit_mode;

    case
    when inserting then     
        log_student_lib.student(log_rec);
    when updating then      
        log_student_lib.student_col(log_rec,'stu_cd'         ,:old.stu_cd         ,:new.stu_cd         );
        log_student_lib.student_col(log_rec,'name'           ,:old.name           ,:new.name           );
        log_student_lib.student_col(log_rec,'kana'           ,:old.kana           ,:new.kana           );
        log_student_lib.student_col(log_rec,'name_e'         ,:old.name_e         ,:new.name_e         );
        log_student_lib.student_col(log_rec,'sex_cd'         ,:old.sex_cd         ,:new.sex_cd         );
        log_student_lib.student_col(log_rec,'birth'          ,:old.birth          ,:new.birth          );
        log_student_lib.student_col(log_rec,'day_eve_cd'     ,:old.day_eve_cd     ,:new.day_eve_cd     );
        log_student_lib.student_col(log_rec,'home_college_cd',:old.home_college_cd,:new.home_college_cd);
        log_student_lib.student_col(log_rec,'fac_cd'         ,:old.fac_cd         ,:new.fac_cd         );
        log_student_lib.student_col(log_rec,'dpt_cd'         ,:old.dpt_cd         ,:new.dpt_cd         );
        log_student_lib.student_col(log_rec,'div_cd'         ,:old.div_cd         ,:new.div_cd         );
        log_student_lib.student_col(log_rec,'lab_cd'         ,:old.lab_cd         ,:new.lab_cd         );
        log_student_lib.student_col(log_rec,'grad'           ,:old.grad           ,:new.grad           );
        log_student_lib.student_col(log_rec,'repeat_cnt'     ,:old.repeat_cnt     ,:new.repeat_cnt     );
        log_student_lib.student_col(log_rec,'div_date'       ,:old.div_date       ,:new.div_date       );
        log_student_lib.student_col(log_rec,'div_seq_no'     ,:old.div_seq_no     ,:new.div_seq_no     );
        log_student_lib.student_col(log_rec,'general_cd'     ,:old.general_cd     ,:new.general_cd     );
        log_student_lib.student_col(log_rec,'course_cd'      ,:old.course_cd      ,:new.course_cd      );
        log_student_lib.student_col(log_rec,'stu_div_cd'     ,:old.stu_div_cd     ,:new.stu_div_cd     );
        log_student_lib.student_col(log_rec,'enter_date'     ,:old.enter_date     ,:new.enter_date     );
        log_student_lib.student_col(log_rec,'old_stu_cd'     ,:old.old_stu_cd     ,:new.old_stu_cd     );
        log_student_lib.student_col(log_rec,'enter_year'     ,:old.enter_year     ,:new.enter_year     );
        log_student_lib.student_col(log_rec,'cur_year'       ,:old.cur_year       ,:new.cur_year       );
        log_student_lib.student_col(log_rec,'fee_year'       ,:old.fee_year       ,:new.fee_year       );
        log_student_lib.student_col(log_rec,'enter_cd'       ,:old.enter_cd       ,:new.enter_cd       );
        log_student_lib.student_col(log_rec,'enter_sub'      ,:old.enter_sub      ,:new.enter_sub      );
        log_student_lib.student_col(log_rec,'due_date'       ,:old.due_date       ,:new.due_date       );
        log_student_lib.student_col(log_rec,'zip_cd'         ,:old.zip_cd         ,:new.zip_cd         );
        log_student_lib.student_col(log_rec,'adr'            ,:old.adr            ,:new.adr            );
        log_student_lib.student_col(log_rec,'tel'            ,:old.tel            ,:new.tel            );
        log_student_lib.student_col(log_rec,'house_cd'       ,:old.house_cd       ,:new.house_cd       );
        log_student_lib.student_col(log_rec,'mobile'         ,:old.mobile         ,:new.mobile         );
        log_student_lib.student_col(log_rec,'e_mail'         ,:old.e_mail         ,:new.e_mail         );
        log_student_lib.student_col(log_rec,'e_mail2'        ,:old.e_mail2        ,:new.e_mail2        );
        log_student_lib.student_col(log_rec,'birth_cd'       ,:old.birth_cd       ,:new.birth_cd       );
        log_student_lib.student_col(log_rec,'origin_cd'      ,:old.origin_cd      ,:new.origin_cd      );
        log_student_lib.student_col(log_rec,'na_cd'          ,:old.na_cd          ,:new.na_cd          );
        log_student_lib.student_col(log_rec,'abroad_cd'      ,:old.abroad_cd      ,:new.abroad_cd      );
        log_student_lib.student_col(log_rec,'need_adr'       ,:old.need_adr       ,:new.need_adr       );
        log_student_lib.student_col(log_rec,'need_name'      ,:old.need_name      ,:new.need_name      );
        log_student_lib.student_col(log_rec,'need_tel'       ,:old.need_tel       ,:new.need_tel       );
        log_student_lib.student_col(log_rec,'elder_cd'       ,:old.elder_cd       ,:new.elder_cd       );
        log_student_lib.student_col(log_rec,'elder_sub'      ,:old.elder_sub      ,:new.elder_sub      );
        log_student_lib.student_col(log_rec,'prom_cd'        ,:old.prom_cd        ,:new.prom_cd        );
        log_student_lib.student_col(log_rec,'due_cd'         ,:old.due_cd         ,:new.due_cd         );
        log_student_lib.student_col(log_rec,'result_cd'      ,:old.result_cd      ,:new.result_cd      );
        log_student_lib.student_col(log_rec,'out_date'       ,:old.out_date       ,:new.out_date       );
        log_student_lib.student_col(log_rec,'out_cd'         ,:old.out_cd         ,:new.out_cd         );
        log_student_lib.student_col(log_rec,'out_sub'        ,:old.out_sub        ,:new.out_sub        );
        log_student_lib.student_col(log_rec,'sr_call' ,:old.sr_call, :new.sr_call); 
        log_student_lib.student_col(log_rec,'sr_kana' ,:old.sr_kana, :new.sr_kana); 
        log_student_lib.student_col(log_rec,'sr_name' ,:old.sr_name, :new.sr_name); 
        log_student_lib.student_col(log_rec,'sr_relation_cd' ,:old.sr_relation_cd, :new.sr_relation_cd);  
        log_student_lib.student_col(log_rec,'sr_zip_cd' ,:old.sr_zip_cd, :new.sr_zip_cd);  
        log_student_lib.student_col(log_rec,'sr_adr' ,:old.sr_adr, :new.sr_adr);  
        log_student_lib.student_col(log_rec,'sr_tel' ,:old.sr_tel, :new.sr_tel);  
        log_student_lib.student_col(log_rec,'sr_mobile' ,:old.sr_mobile, :new.sr_mobile); 
        log_student_lib.student_col(log_rec,'pr_kana' ,:old.pr_kana, :new.pr_kana);  
        log_student_lib.student_col(log_rec,'pr_name' ,:old.pr_name, :new.pr_name);  
        log_student_lib.student_col(log_rec,'pr_relation_cd' ,:old.pr_relation_cd, :new.pr_relation_cd);  
        log_student_lib.student_col(log_rec,'pr_zip_cd' ,:old.pr_zip_cd, :new.pr_zip_cd);  
        log_student_lib.student_col(log_rec,'pr_adr' ,:old.pr_adr, :new.pr_adr);  
        log_student_lib.student_col(log_rec,'pr_tel' ,:old.pr_tel, :new.pr_tel);  
        log_student_lib.student_col(log_rec,'pr_mobile' ,:old.pr_mobile, :new.pr_mobile);  
        log_student_lib.student_col(log_rec,'office' ,:old.office, :new.office); 
        log_student_lib.student_col(log_rec,'office_zip_cd' ,:old.office_zip_cd, :new.office_zip_cd);  
        log_student_lib.student_col(log_rec,'office_adr' ,:old.office_adr, :new.office_adr);  
        log_student_lib.student_col(log_rec,'office_tel' ,:old.office_tel, :new.office_tel);  
        log_student_lib.student_col(log_rec,'office_mail' ,:old.office_mail, :new.office_mail);
        log_student_lib.student_col(log_rec,'career_cd' ,:old.career_cd, :new.career_cd);  
        log_student_lib.student_col(log_rec,'results_send_cd' ,:old.results_send_cd, :new.results_send_cd); 
    when deleting then       
        log_student_lib.student(log_rec);
    end case;

    if a_edit_div = '1' then
        :new.base_edit_dt   := sysdate;   
        :new.base_edit_user := user   ;   
    end if;
end;

/
