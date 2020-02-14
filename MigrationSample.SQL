/* Copy Right 2020 Kentaro Kurose */

/* Sample script for Data Migration                        */
/* Just a sample source and does'nt work by itself         */
/* Dare to use magic number and remaim japanese Charcters  */
/* Some values are masked/deleted to protect information   */

create or replace package XXXXX.MIG_LIB
is
    procedure test_main(
        i_dummy  in     varchar2   
    );
    
    
    function get_out_code_for_uni(
        i_out_cd   in     varchar2 
    )return varchar2;
    function get_out_code_for_gra(
        i_out_cd   in     varchar2 
    )return varchar2;

    function get_cd_from_origin(
                i_origin_name in varchar2
        ) return varchar2;
    function get_cd_from_nation(
                i_nation_name in varchar2
        ) return varchar2;
    function to_number(
        str varchar2
    ) return number;
    procedure date_to_ymd(
        i_date      in  varchar2,
        i_delimiter in  varchar2,
        i_y         out varchar2,
        i_m         out varchar2,
        i_d         out varchar2
    );

   function is_current_student(
        i_id in     varchar2  -- ID
    ) return varchar2;

    function is_english(
        i_str varchar2
    ) return varchar2;
    function replace_new_line(
        i_str varchar2
    ) return varchar2;
   procedure set_reg_out_info(
        i_id       in  varchar2, 
        S_OUT_DATE out varchar2, 
        S_OUT_CD   out varchar2, 
        S_OUT_SUB  out varchar2, 
        S_OUT_YEAR out varchar2  
    );
    function get_period_from_stu_cd_header(
        i_stu_2_cd   in     varchar2
    )return varchar2;
    function get_process(
        i_process      in     varchar2,
        i_stu_cd     in     varchar2 
    )return varchar2;
    function get_stu_div_cd(
        i_mrec             in mdb.m_doctor%rowtype, 
        i_srec             in      student%rowtype, 
        o_note             out         varchar2     
    )return varchar2;

    function get_stu_div_cd_by_scd_fac(
        i_stu_cd_header      in     varchar2, 
        i_stu_cd_5th         in     varchar2, 
        i_stu_cd_6th         in     varchar2, 
        i_fac_cd             in     varchar2  
    )return varchar2;
    function get_stu_div_cd_by_kti_kubun(
        i_process              in     varchar2, 
        i_student_kubun      in     number    
    )return varchar2;

    procedure get_fac_dpt_cd(
        i_mrec             in     mdb.m_doctor%rowtype,  
        o_fac_cd           out    varchar2,              
        o_dpt_cd           out    varchar2,              
        o_txt              out    varchar2  
    );
    procedure get_fac_dpt_div_cd(
        i_mrec             in     mdb.m_doctor%rowtype, 
        o_fac_cd           out    varchar2,             
        o_dpt_cd           out    varchar2,             
        o_div_cd           out    varchar2,             
        o_txt              out    varchar2  
    );
    procedure get_fac_dpt_div_lab_cd(
        i_mrec             in     mdb.m_doctor%rowtype, 
        o_fac_cd           out    varchar2,             
        o_dpt_cd           out    varchar2,             
        o_div_cd           out    varchar2,             
        o_lab_cd           out    varchar2,             
        o_txt              out    varchar2  
    );
    function get_regular_cd(
        i_stu_div_cd       in     varchar2               
    )return varchar2;                                    
    function get_elder_cd(
        i_mrec             in     mdb.m_doctor%rowtype   
    )return varchar2;                                    
    function get_abroad_cd(
        i_mrec             in     mdb.m_doctor%rowtype   
    )return varchar2;                                    
    procedure get_na_cd(
        i_mrec             in     mdb.m_doctor%rowtype,  
        o_origin_cd        out    varchar2,              
        o_na_cd            out    varchar2               
    );
    function get_sr_relation_cd(
        i_mrec             in     mdb.m_doctor%rowtype   
    )return varchar2;                                    
    /*---------- QA004.Destination list  ----------*/
    procedure get_adjust_data_indivisually(
        i_mrec             in     mdb.m_doctor%rowtype,  
        o_fac_cd           out    varchar2,              
        o_dpt_cd           out    varchar2,              
        o_div_cd           out    varchar2,              
        o_lab_cd           out    varchar2,              
        o_match            out    varchar2               
   );


end;
/

create or replace package BODY XXXXX.MIG_LIB
is

    procedure test_main(
        i_dummy  in     varchar2   -- Dummy
    )
    is
        a_number number;
        a_s_timestamp TIMESTAMP(3) WITH TIME ZONE;
        a_e_timestamp TIMESTAMP(3) WITH TIME ZONE;
    begin
    
        set transaction isolation level serializable;
        savepoint B4_MIG001;
        
        a_s_timestamp := CURRENT_TIMESTAMP;
        
        commit;
        
        a_e_timestamp := CURRENT_TIMESTAMP;
        
        MIG_LOGGER.write_log(a_s_timestamp,a_e_timestamp,'ok','DummyID','procedure test_main committed',NULL);
        
        exception
            when others -- catch all Exceptions
                then
                    rollback to savepoint B4_MIG001;
                    dbms_output.put_line('An exception occured(sqlcode):'||sqlcode);
                       dbms_output.put_line('                    (sqlerrm):'||sqlerrm);
                    MIG_LOGGER.write_log('ng','An exception occured(sqlcode):'||sqlcode);
                    MIG_LOGGER.write_log('ng','                    (sqlerrm):'||sqlerrm);
                    MIG_LOGGER.write_log('ng','start rolling back to savepoint B4_MIG001');
                    MIG_LOGGER.write_log('ng','finish rolling back to savepoint B4_MIG001');
    end;




--    function get_new_stu_code(
--        i_header   in     varchar2  
--    )return varchar2                
--    is
--        a_lenghth_of_header         number;
--        a_stu_code                     varchar2(10);
--        a_num_of_sequence_row         number;
--        a_currval                    number;
--        a_nextval                    number;
--        a_length_of_ordered_number     number;
--        c_stu_cd_length             number := 8;
--    begin
--        a_lenghth_of_header := length(i_header); 
--        
--        if(a_lenghth_of_header<5 or 6<a_lenghth_of_header)
--            then RAISE_APPLICATION_ERROR(-20000,'');
--        end if; 
--        
--        select count(*) into a_num_of_sequence_row 
--            from MIG_SEQ_TABLE where str = i_header;
--        MIG_LOGGER.write_log('sql',
--            'select count(*) into a_num_of_sequence_row from MIG_SEQ_TABLE where str = i_header;'||
--            'a_num_of_sequence_row='||a_num_of_sequence_row||' i_header='||i_header
--        );
--            
--        if(a_num_of_sequence_row<1)
--            then insert into MIG_SEQ_TABLE values(i_header,0,1);
--            MIG_LOGGER.write_log('sql',
--                'insert into MIG_SEQ_TABLE values(i_header,0,1);'||'i_header='||i_header
--            );
--        end if;
--        
--        a_length_of_ordered_number := c_stu_cd_length-LENGTH(i_header);
--        
--        if(a_length_of_ordered_number<1) then RAISE_APPLICATION_ERROR('i_header:'||i_header,20000);
--        end if;
--        
--        select CONCAT(STR,LPAD(TO_CHAR(nextval),a_length_of_ordered_number,'0')),currval,nextval into a_stu_code,a_currval,a_nextval
--            from MIG_SEQ_TABLE where str = i_header;
--        MIG_LOGGER.write_log('sql',
--            'select CONCAT(STR,LPAD(TO_CHAR(nextval),a_length_of_ordered_number,'||0||')),currval,nextval into a_stu_code,a_currval,a_nextval 
--            ' a_currval='||a_currval||' a_nextval='||a_nextval||' a_length_of_ordered_number='||a_length_of_ordered_number||' i_header='||i_header
--        );
--
--        if(mod(a_nextval,power(10,a_length_of_ordered_number))=0) 
--            then RAISE_APPLICATION_ERROR(-20000,'over limitation '||a_nextval||' HEADER='||i_header);
--        end if; 
--        
--        a_currval := a_currval+1;
--        a_nextval := a_nextval+1;
--        
--        update MIG_SEQ_TABLE set currval = a_currval, nextval = a_nextval
--            where str = i_header;
--        MIG_LOGGER.write_log('sql',
--            'update MIG_SEQ_TABLE set currval = a_currval, nextval = a_nextval
--            where str = i_header;'||
--            ' a_currval='||a_currval||
--            ' a_nextval='||a_nextval||
--            ' i_header='||i_header
--        );
--        return a_stu_code;
--    end;
--
--
--


--    procedure insert_student(
--        i_year  in     varchar2  
--    )
--    is
--        a_stu_idx        varchar(40);
--        a_stu_id        varchar(24);
--        a_stu_cd_header    varchar(40);
--        a_stu_cd        varchar(40);
--        a_s_timestamp TIMESTAMP(3) WITH TIME ZONE;
--        a_e_timestamp TIMESTAMP(3) WITH TIME ZONE;

--        --type stu_org_type is table of <OrgTable>%rowtype index by pls_integer;
--        --stu_org_table stu_org_type;
--        cursor c_stu_org is select * from <OrgTable
--            where <Cond>;
--    begin
--    
--        for stu_org_rec in c_stu_org loop;
--    
--            a_s_timestamp := CURRENT_TIMESTAMP;                
--            
--            --select * bulk collect into stu_org_table from <OrgTable>
--            --    where 1=1;             
--            
--            student_id_lib.get_student_id(i_year,a_stu_id);   
--            a_stu_idx     := i_year || a_stu_id;              
--
--            case <StudentType>
--                when <StudentTypeA> then                                   
--                    a_stu_cd_header := get_<StudentTypeA>_cd_header();
--                when <StudentTypeB> then                               
--                    a_stu_cd_header := get_<StudentTypeB>_cd_header();
--                when <StudentTypeC> then                               
--                    a_stu_cd_header := get_<StudentTypeC>_cd_header();
--                when <StudentTypeD> then                               
---                    a_stu_cd_header := get_<StudentTypeD>_cd_header();
--                when <StudentTypeE> then                               
--                    a_stu_cd_header := get_<StudentTypeE>_cd_header();
--                when <StudentTypeS> then               
--                    a_stu_cd_header := get_<StudentTypeS>_cd_header();
--                else
--                    RAISE_APPLICATION_ERROR(-20000,'Unexpected');
--            end case;
--            
--            a_stu_cd    := get_new_stu_code(a_stu_cd_header); 

--            a_e_timestamp := CURRENT_TIMESTAMP;            
--            
--            MIG_LOGGER.write_log(
--                a_s_timestamp,
--                a_e_timestamp,
--                'DummyFlag',
--                'DummyID',
--                'insert XXXXXXX',
--                NULL
--            );
--            
--        end loop;
--
--    end;
--
--
--    function get_<XXXXX>_cd_header()
--        i_year  in     varchar2   -- XXXXX
--    ) return varchar2
--    is
--    begin
--        return '';
--    end;
--    function get_<XXXXX>_cd_header()
--        i_year  in     varchar2   -- XXXXX
--    ) return varchar2
--    is
--    begin
--        return '';
--    end;
--    function get_<XXXXX>_cd_header()
--        i_year  in     varchar2   -- XXXXX
--    ) return varchar2
--    is
--    begin
--        return '';
--    end;
--    function get_<XXXXX>_cd_header()
--        i_year  in     varchar2   -- XXXXX
--    ) return varchar2
--    is
--    begin
--        return '';
--    end;
--    function get_<XXXXX>_cd_header()
--        i_year  in     varchar2   -- XXXXX
--    ) return varchar2
--    is
--    begin
--        return '';
--    end;
--


    function get_out_code_for_uni(
        i_out_cd   in     varchar2 --> 
    ) return varchar2
        is
        out_cd varchar2(2);
    begin
        out_cd := null;
        case i_out_cd
            when '1' then out_cd := '01'; -- 'Graduate'
            when '2' then out_cd := '05'; -- 'Out'
            else null;
        end case;
        return out_cd ;
        end;

    function get_out_code_for_gra(
        i_out_cd   in     varchar2 --> GraUni
    ) return varchar2
        is
        out_cd varchar2(2);
    begin
        out_cd := null;
        case i_out_cd
            when '1' then out_cd := '02'; -- 'Termination'
            when '2' then out_cd := '01'; -- 'Completion'
            else null;
        end case;
        return out_cd ;
    end;

    function get_process_from_process(
        i_process      in     varchar2 -->
    )return varchar2
    is
        out_process varchar2(100);
    begin
       case i_process
           when '01' then out_process:='StudentTypeA';
           when '02' then out_process:='StudentTypeB';
           when '03' then out_process:='StudentTypeC';
           when '04' then out_process:='StudentTypeD';
           when '05' then out_process:='StudentTypeE';
           when '08' then out_process:='StudentTypeF';
           when '09' then out_process:='StudentTypeG';
           when '10' then out_process:='StudentTypeH';
           when '11' then out_process:='StudentTypeI';
           when '12' then out_process:='StudentTypeJ';
           when '13' then out_process:='StudentTypeK';
           when '14' then out_process:='StudentTypeL';
           else           out_process:=null;
       end case;
       return out_process ;
    end;

    function get_process(
        i_process    in     varchar2, --> XXXXX
        i_stu_cd     in     varchar2  --> XXXXX
    )return varchar2
        is
        a_period_from_stu_cd_header varchar2(100);
        a_process_from_process          varchar2(100);
        a_process_ret         varchar2(100);
        a_stu_cd_header     varchar2(2);
    begin
        a_stu_cd_header := substr(i_stu_cd,1,2);
        a_period_from_stu_cd_header := get_period_from_stu_cd_header(a_stu_cd_header);
        a_process_from_process          := get_process_from_process(i_process);

        if(a_process_from_process is null) then
            a_process_ret     :=a_period_from_stu_cd_header;
        else
            a_process_ret     :=a_process_from_process;
        end if;
       
        a_period_from_stu_cd_header:=nvl(a_period_from_stu_cd_header,'(XXXXX)');
        a_process_from_process         :=nvl(a_process_from_process,         '(XXXXX)');
        if(a_period_from_stu_cd_header<>a_process_from_process) then
            mig_logger.write_log('DKTI',i_stu_cd,'[XXXXX][XXXXX]'||a_period_from_stu_cd_header||'[XXXXX]'||a_process_from_process);
        end if;
       
        return a_process_ret ;
    end;

    function get_period_from_stu_cd_header(
        i_stu_2_cd   in     varchar2 --> XXXXX
    )return varchar2
        is
        out_cd varchar2(100);
    begin
        out_cd := null;
        case i_stu_2_cd
            when '23' then out_cd := 'XXXXX';
            when '24' then out_cd := 'XXXXX';
            when '26' then out_cd := 'XXXXX';
            when '27' then out_cd := 'XXXXX';
            else           out_cd := null;
        end case;
        return out_cd ;
    end;
        

     function get_cd_from_origin(
         i_origin_name in varchar2
     ) return varchar2
     is
         cursor c1 is select * from origin where name like '%'||i_origin_name||'%';
         c1_rec c1%rowtype;
         r_cd varchar2(10):=null;
     begin
         open c1;
         fetch c1 into c1_rec;
         if c1%found then r_cd := c1_rec.origin_cd ;
         end if;
         close c1;
         return r_cd;
     end;

     function get_cd_from_nation(
         i_nation_name in varchar2
     ) return varchar2
     is
         cursor c1 is select * from nation where name = i_nation_name;
         c1_rec c1%rowtype;
         r_cd varchar2(10):=null;
     begin
         open c1;
         fetch c1 into c1_rec;
         if c1%found then r_cd := c1_rec.na_cd ;
         end if;
         close c1;
         return r_cd;
     end;

     function to_number(
         str varchar2
     ) return number
     is
     begin
      return to_number(str);
     exception when others then
      return null;
     end;

     procedure date_to_ymd(
         i_date      in  varchar2,
         i_delimiter in  varchar2,
         i_y         out varchar2,
         i_m         out varchar2,
         i_d         out varchar2
     )
     is
       i_date_md varchar2(10);
     begin
         if(INSTR(i_date,i_delimiter)<1) then
             i_y:=null;
             i_m:=null;
             i_d:=null;
         else
             i_y  := substr(i_date,1,INSTR(i_date,i_delimiter)-1);
             i_date_md := substr(i_date,INSTR(i_date,i_delimiter)+1,LENGTH(i_date));
             i_m := substr(i_date_md,0,INSTR(i_date_md,i_delimiter)-1);
             i_d := substr(i_date_md,INSTR(i_date_md,i_delimiter)+1,LENGTH(i_date_md));
             if(i_m is not null and length(i_m)=1) then i_m:=LPAD(i_m,2,'0');end if;
             if(i_d is not null and length(i_d)=1) then i_d:=LPAD(i_m,2,'0');end if;
             if(i_y is not null and length(i_y)>4) then i_y:=null           ;end if;
             if(i_m is not null and length(i_m)>2) then i_m:=null           ;end if;
             if(i_d is not null and length(i_d)>2) then i_d:=null           ;end if;
         end if;
         
         mig_logger.write_log(i_date,'MIG_LIB','i_y='||i_y||' i_m='||i_m||' i_d='||i_d);
     end;


        function is_current_student(
            i_id in     varchar2  -- ID
        ) return varchar2
        is
          cursor c1 is
            select * from MDB.MIG_REG_OUT
              where id=i_id;
          a_retval varchar2(1);
        begin
            a_retval := '1';
            for c1_rec in c1 loop
                if(c1_rec.S_OUT_CD is not null)
                  then a_retval := '2';
                end if;
            end loop;
            return a_retval;
        end;
        function is_english(
            i_str varchar2
        ) return varchar2 
        is
          a_retval varchar2(1);
          a_1char  varchar2(3);
        begin

            if(i_str is null) then return '0';
            end if;
            a_retval:='1';
            for position in 1..length(i_str) loop
              a_1char:=substr(i_str,position,1);
              if(
                (a_1char='A')
              or(a_1char='B')
              or(a_1char='C')
              or(a_1char='D')
              or(a_1char='E')
              or(a_1char='F')
              or(a_1char='G')
              or(a_1char='H')
              or(a_1char='I')
              or(a_1char='J')
              or(a_1char='K')
              or(a_1char='L')
              or(a_1char='M')
              or(a_1char='N')
              or(a_1char='O')
              or(a_1char='P')
              or(a_1char='Q')
              or(a_1char='R')
              or(a_1char='S')
              or(a_1char='T')
              or(a_1char='U')
              or(a_1char='V')
              or(a_1char='W')
              or(a_1char='X')
              or(a_1char='Y')
              or(a_1char='Z')
              or(a_1char='a')
              or(a_1char='b')
              or(a_1char='c')
              or(a_1char='d')
              or(a_1char='e')
              or(a_1char='f')
              or(a_1char='g')
              or(a_1char='h')
              or(a_1char='i')
              or(a_1char='j')
              or(a_1char='k')
              or(a_1char='l')
              or(a_1char='m')
              or(a_1char='n')
              or(a_1char='o')
              or(a_1char='p')
              or(a_1char='q')
              or(a_1char='r')
              or(a_1char='s')
              or(a_1char='t')
              or(a_1char='u')
              or(a_1char='v')
              or(a_1char='w')
              or(a_1char='x')
              or(a_1char='y')
              or(a_1char='0')
              or(a_1char='1')
              or(a_1char='2')
              or(a_1char='3')
              or(a_1char='4')
              or(a_1char='5')
              or(a_1char='6')
              or(a_1char='7')
              or(a_1char='8')
              or(a_1char='9')
              or(a_1char='Ç`')
              or(a_1char='Ça')
              or(a_1char='Çb')
              or(a_1char='Çc')
              or(a_1char='Çd')
              or(a_1char='Çe')
              or(a_1char='Çf')
              or(a_1char='Çg')
              or(a_1char='Çh')
              or(a_1char='Çi')
              or(a_1char='Çj')
              or(a_1char='Çk')
              or(a_1char='Çl')
              or(a_1char='Çm')
              or(a_1char='Çn')
              or(a_1char='Ço')
              or(a_1char='Çp')
              or(a_1char='Çq')
              or(a_1char='Çr')
              or(a_1char='Çs')
              or(a_1char='Çt')
              or(a_1char='Çu')
              or(a_1char='Çv')
              or(a_1char='Çw')
              or(a_1char='Çx')
              or(a_1char='Çy')
              or(a_1char='ÇÅ')
              or(a_1char='ÇÇ')
              or(a_1char='ÇÉ')
              or(a_1char='ÇÑ')
              or(a_1char='ÇÖ')
              or(a_1char='ÇÜ')
              or(a_1char='Çá')
              or(a_1char='Çà')
              or(a_1char='Çâ')
              or(a_1char='Çä')
              or(a_1char='Çã')
              or(a_1char='Çå')
              or(a_1char='Çç')
              or(a_1char='Çé')
              or(a_1char='Çè')
              or(a_1char='Çê')
              or(a_1char='Çë')
              or(a_1char='Çí')
              or(a_1char='Çì')
              or(a_1char='Çî')
              or(a_1char='Çï')
              or(a_1char='Çñ')
              or(a_1char='Çó')
              or(a_1char='Çò')
              or(a_1char='Çô')
              or(a_1char='ÇO')
              or(a_1char='ÇP')
              or(a_1char='ÇQ')
              or(a_1char='ÇQ')
              or(a_1char='ÇR')
              or(a_1char='ÇS')
              or(a_1char='ÇT')
              or(a_1char='ÇU')
              or(a_1char='ÇV')
              or(a_1char='ÇW')
              or(a_1char='ÇX')
              or(a_1char=' ')
              or(a_1char='-')
              or(a_1char='.')
              or(a_1char='?')
              or(a_1char='"')
              or(a_1char='Åh')
              or(a_1char='Éø')
              or(a_1char='É¿')
              or(a_1char='É¡')
              or(a_1char='\r')
              or(a_1char='\n')
              or(a_1char='/')
              or(a_1char='(')
              or(a_1char=')')
              or(a_1char='Åf')
              or(a_1char='É»')
              or(a_1char='áT')
              or(a_1char='áU')
              or(a_1char='áV')
              or(a_1char='áW')
              or(a_1char='áX')
              or(a_1char='áY')
              or(a_1char='áZ')
              or(a_1char='á[')
              or(a_1char='á\')
              or(a_1char='á]')
              or(a_1char='˙@')
              or(a_1char='˙A')
              or(a_1char='˙B')
              or(a_1char='˙C')
              or(a_1char='˙D')
              or(a_1char='˙E')
              or(a_1char='˙F')
              or(a_1char='˙G')
              or(a_1char='˙H')
              or(a_1char='˙I')
              or(a_1char=CHR(9)) --\t
              or(a_1char=CHR(10))--\r
              or(a_1char=CHR(13))--\n
              or(a_1char=CHR(10)||CHR(13))--\r\n
              or(a_1char=CHR(20))--Space
              or(a_1char=CHR(32))--Space
              or(a_1char=CHR(39))--'
              or(a_1char=CHR(95))--_
              or(a_1char=CHR(91))--[
              or(a_1char=CHR(61))--=
              or(a_1char=CHR(60))--<
              or(a_1char=CHR(59))--;
              or(a_1char=CHR(58))--:
              or(a_1char=CHR(53434))--Ñ{
              or(a_1char=CHR(52924))--É 
              or(a_1char=CHR(52921))--É«
              or(a_1char=CHR(52917))--É√
              or(a_1char=CHR(52916))--É¬
              or(a_1char=CHR(52884))--É¢
              or(a_1char=CHR(44))--,
              or(a_1char=CHR(43))--+
              or(a_1char=CHR(37))--%
              or(a_1char=CHR(15711642))--Çö
              or(a_1char=CHR(15711391))--ÅH
              or(a_1char=CHR(15711386))--ÅF
              or(a_1char=CHR(15711374))--ÅD
              or(a_1char=CHR(15711373))--Å|
              or(a_1char=CHR(15711372))--ÅC
              or(a_1char=CHR(15711371))--Å{
              or(a_1char=CHR(15711369))--)
              or(a_1char=CHR(15711368))--(
              or(a_1char=CHR(14909580))--Åu
              or(a_1char=CHR(14909568))--Space
              or(a_1char=CHR(14844060))--Åg
              or(a_1char=CHR(14844056))--Åe
              or(a_1char=CHR(14844053))--Å\
              or(a_1char=CHR(14844048))--Å]
              or(a_1char=CHR(14909581))--Åv
              or(a_1char=CHR(42))--*
              or(a_1char=CHR(93))--]
              or(a_1char=CHR(122))--z
              or(a_1char='XXXXX')--Thesis suffix 1
              or(a_1char='XXXXX')--Thesis suffix 2
              )
                then 
                null;
              else
               --mig_logger.write_log('ASCII',a_1char,''||ASCII(a_1char));
               a_retval:='2';
                exit;
              end if;
            end loop;
            return a_retval;
        end;

        function replace_new_line(
            i_str varchar2
        ) return varchar2  
        is
            a_retval varchar2(1000);
        begin
            select replace (i_str,CHR(10),' ')    into a_retval from dual;
            select replace (a_retval,CHR(13),' ') into a_retval from dual;
            return a_retval;
        end;

/* èoäwèÓïÒÇÃê›íË */
       procedure set_reg_out_info(
            i_id       in  varchar2, 
            s_out_date out varchar2, 
            s_out_cd   out varchar2, 
            s_out_sub  out varchar2, 
            s_out_year out varchar2  
        )
        is
          cursor c1 is
            select * from MDB.MIG_REG_OUT
              where id=i_id
                order by no desc;
        begin
            for c1_rec in c1 loop
                 if(
                       c1_rec.s_out_cd='02' 
                   or  c1_rec.s_out_cd='03' 
                   or  c1_rec.s_out_cd='05' 
                   or  c1_rec.s_out_cd='06' 
                   or  c1_rec.s_out_cd='07' 
                   or  c1_rec.s_out_cd='08' 
                   or  c1_rec.s_out_cd='10' 
                   or  c1_rec.s_out_cd='21' 
                 ) then
                    s_out_date := c1_rec.s_out_date;
                    s_out_cd   := c1_rec.s_out_cd;
                    s_out_sub  := c1_rec.s_out_sub;
                    s_out_year := c1_rec.s_out_year;
                    exit when (1=1);
                 end if;
            end loop;
        end;


    function get_stu_div_cd(
        i_mrec             in          mdb.m_doctor%rowtype,  
        i_srec             in          student%rowtype,       
        o_note             out         varchar2               
    )return varchar2
    is
        a_out_cd                  varchar2(2);
        a_stu_div_cd_by_scd_fac   varchar2(2);
        a_stu_div_cd_by_kti_kubun varchar2(2);
        a_stu_cd_header           varchar2(2); 
        a_stu_cd_5th_ch           varchar2(1); 
        a_stu_cd_6th_ch           varchar2(1); 


        a_fac_name               varchar2(100);
        a_dpt_name               varchar2(100);
        a_div_name               varchar2(100);
        a_lab_name               varchar2(100);

    begin
        a_stu_div_cd_by_kti_kubun := get_stu_div_cd_by_kti_kubun(i_mrec.XXXXX,i_mrec.XXXXX);

        mig_logger.write_log('D001',i_mrec.XXXXX,' [a_stu_div_cd_by_kti_kubun=]'||a_stu_div_cd_by_kti_kubun);

        a_stu_cd_header := substr(i_mrec.XXXXX,1,2);
        a_stu_cd_5th_ch := substr(i_mrec.XXXXX,5,1);
        a_stu_cd_6th_ch := substr(i_mrec.XXXXX,6,1);
        a_stu_div_cd_by_scd_fac := get_stu_div_cd_by_scd_fac(a_stu_cd_header,a_stu_cd_5th_ch,a_stu_cd_6th_ch,i_srec.fac_cd);

        mig_logger.write_log('D002',i_mrec.XXXXX,' [a_stu_div_cd_by_scd_fac=]'||a_stu_div_cd_by_scd_fac);

        -- ÉçÉO
        if(a_stu_div_cd_by_kti_kubun=a_stu_div_cd_by_scd_fac)
        then
            a_out_cd := a_stu_div_cd_by_kti_kubun;
            o_note   := null;
            mig_logger.write_log('DCHKS',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
        else
            -- Pattern DPTRNX1 QA No.003 Doctor
            if   (i_mrec.XXXXX='XXXXX0001' or i_mrec.XXXXX='XXXXX001')
                then 
                a_out_cd := '21';
                mig_logger.write_log('DPTRNX1',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);

            -- Pattern DPTRNX2 QA No.004 Doctor 4 years
            elsif(a_stu_cd_header='43')
                then 
                a_out_cd := '15';
                mig_logger.write_log('DPTRNX2',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);

            -- Pattern DPTRNX3 QA No.XXX XXXXX/96
            elsif(a_stu_cd_header='48')
                then 
                a_out_cd := '21';
                mig_logger.write_log('DPTRNX3',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                --o_note   := '[XXXXX][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX;

            -- Pattern DPTRNX4 QA No.XXX from the QA list  62->XXXXX[Previous term]XXXXX/362 number(s)
            elsif(a_stu_cd_header='62')
                then 
                a_out_cd := '12';
                mig_logger.write_log('DPTRNX4',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                --o_note   := '[XXXXX][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX;

            -- Pattern DPTRNX5 QA No.XXX from the QA list  63->XXXXX[Latter term]XXXXX/144 number(s)
            elsif(a_stu_cd_header='63')
                then 
                a_out_cd := '13';
                mig_logger.write_log('DPTRNX5',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                --o_note   := '[XXXXX][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX;

            -- Pattern DPTRNX6 QA No.XXX from the QA list  67->StudentTypeBio/35 number(s)
            elsif(a_stu_cd_header='67')
                then 
                a_out_cd := '44';
                mig_logger.write_log('DPTRNX6',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                --o_note   := '[XXXXX][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX;

            -- Pattern DPTRNX7 QA No.XXX from the QA list  68->Life Information ..(snip)..DepartmentXXXXX(Accepting guidance)/35 number(s)
            elsif(a_stu_cd_header='68')
                then 
                a_out_cd := '21';
                mig_logger.write_log('DPTRNX7',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                --o_note   := '[XXXXX][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX;

            -- Pattern DPTRNX8 QA No.XXX from the QA list  68->Life Information ..(snip)..DepartmentXXXXX(Accepting guidance)/347 number(s)
            elsif(a_stu_cd_header='71')
                then 
                a_out_cd := '31';
                mig_logger.write_log('DPTRNX8',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                --o_note   := '[XXXXX][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX;

            -- Pattern 1 From old code to  12 from XXXXX to  74(Unknown/1 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='12' and a_stu_div_cd_by_scd_fac='74')
                then 
                mig_logger.write_log('DPTRN01',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '98';
                o_note   := '[XXXXX][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX;

            -- Pattern 2 From old code to  12 from XXXXX to  98(DoctorXXXXX[Previous term]12[ treat as ]/365 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='12' and a_stu_div_cd_by_scd_fac='98')
                then
                mig_logger.write_log('DPTRN02',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '12';
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 3  From old code to  92 from XXXXX to  12(DoctorXXXXX[Previous term]12[ treat as ]/7 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='92' and a_stu_div_cd_by_scd_fac='12')
                then
                mig_logger.write_log('DPTRN02',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '12';
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;


            -- Pattern 4 From old code to  13 from XXXXX to  98(DoctorXXXXX[Latter term]13[ treat as ]/155 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='13' and a_stu_div_cd_by_scd_fac='98')
                then
                mig_logger.write_log('DPTRN04',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '13';
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 5 From old code to  92 from XXXXX to  13(DoctorXXXXX[Latter term]13[ treat as ]/28 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='92' and a_stu_div_cd_by_scd_fac='13')
                then
                mig_logger.write_log('DPTRN05',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '13';
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 6 From old code to  92 from XXXXX to  15(DoctorXXXXX( 4 years)15[ treat as ]/110 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='92' and a_stu_div_cd_by_scd_fac='15')
                then
                mig_logger.write_log('DPTRN06',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '15'; -- 'DoctorXXXXX( 4 years)'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 7 From old code to  49 from XXXXX to  21(XXXXX21/174 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='49' and a_stu_div_cd_by_scd_fac='21')
                then
                mig_logger.write_log('DPTRN07',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '21'; -- 'XXXXX'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 8 From old code to  98 from XXXXX to  21(XXXXX21/6 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='98' and a_stu_div_cd_by_scd_fac='21')
                then
                mig_logger.write_log('DPTRN08',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '21'; -- 'XXXXX'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 9 From old code to  39 from XXXXX to  31(Graduate student31/88 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='39' and a_stu_div_cd_by_scd_fac='31')
                then
                mig_logger.write_log('DPTRN09',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '31'; -- 'Graduate student'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 10 From old code to  39 from XXXXX to  32(Graduate student32/4 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='39' and a_stu_div_cd_by_scd_fac='32')
                then
                mig_logger.write_log('DPTRN10',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '32'; -- 'Graduate student'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 11 From old code to  39 from XXXXX to  33(Graduate student33/2 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='39' and a_stu_div_cd_by_scd_fac='33')
                then
                mig_logger.write_log('DPTRN11',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '33'; -- 'Graduate student'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 12 From old code to  98 from XXXXX to  33(Graduate student33[ treat as ]/4 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='98' and a_stu_div_cd_by_scd_fac='33')
                then
                mig_logger.write_log('DPTRN12',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '33'; -- 'Graduate student'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 13 From old code to  39 from XXXXX to  98(Graduate student31[ treat as ]/347 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='39' and a_stu_div_cd_by_scd_fac='98')
                then
                mig_logger.write_log('DPTRN13',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '31'; -- 'Graduate student'
                o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 14 From old code to  49 from XXXXX to  98(Graduate student31[ treat as ]/10 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='49' and a_stu_div_cd_by_scd_fac='98')
                then
                mig_logger.write_log('DPTRN14',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '21'; -- 'Graduate student'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 15 From old code to  49 from XXXXX to  98(Graduate student31[ treat as ]/10 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='49' and a_stu_div_cd_by_scd_fac='98')
                then
                mig_logger.write_log('DPTRN14',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '21'; -- 'Graduate student'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 16 From old code to  79 from XXXXX to  7Y(Graduate student31[ treat as ]/347 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='79' and a_stu_div_cd_by_scd_fac='7Y')
                then
                mig_logger.write_log('DPTRN16',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                -- from XXXXX to XXXXXÇîªíË
                   if(a_stu_cd_header='20') then a_out_cd := '71'; -- 'Course students[XXXXX]'
                                                 mig_logger.write_log('DPT16A'||a_stu_cd_header,i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                elsif(a_stu_cd_header='23') then a_out_cd := '71'; -- 'Course students[XXXXX]'
                                                 mig_logger.write_log('DPT16B'||a_stu_cd_header,i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                elsif(a_stu_cd_header='24') then a_out_cd := '72'; -- 'Course students[Inspection]'
                                                 mig_logger.write_log('DPT16C'||a_stu_cd_header,i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                elsif(a_stu_cd_header='25') then a_out_cd := '71'; -- 'Course students[XXXXX]'
                                                 mig_logger.write_log('DPT16D'||a_stu_cd_header,i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                elsif(a_stu_cd_header='26') then a_out_cd := '71'; -- 'Course students[XXXXX]'
                                                 mig_logger.write_log('DPT16E'||a_stu_cd_header,i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                elsif(a_stu_cd_header='27') then a_out_cd := '72'; -- 'Course students[Inspection]'
                                                 mig_logger.write_log('DPT16F'||a_stu_cd_header,i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                elsif(a_stu_cd_header='30') then a_out_cd := '73'; -- 'Course students[XXXXXProfessional]'
                                                 mig_logger.write_log('DPT16G'||a_stu_cd_header,i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                else
                                                 mig_logger.write_log('DPT16Z'||a_stu_cd_header,i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);




                    -- Judge
                     mig_logger.write_log('D7Z001',i_mrec.XXXXX,
                     '[a_stu_cd_header=]'||a_stu_cd_header||
                     '[i_srec.fac_cd=]'||nvl(i_srec.fac_cd,'NULL')||
                     '[i_srec.dpt_cd=]'||nvl(i_srec.dpt_cd,'NULL')||
                     '[i_srec.div_cd=]'||nvl(i_srec.div_cd,'NULL')||
                     '[i_srec.lab_cd=]'||nvl(i_srec.lab_cd,'NULL'));
                    -- select name into a_fac_name from faculty    where fac_cd=i_srec.fac_cd;
                    -- mig_logger.write_log('D7Z002',i_mrec.XXXXX,'DUMMY');
                    select name into a_dpt_name from department where fac_cd=i_srec.fac_cd and dpt_cd=i_srec.dpt_cd;
                    mig_logger.write_log('D7Z003',i_mrec.XXXXX,'DUMMY');
                    -- select name into a_div_name from division   where fac_cd=i_srec.fac_cd and dpt_cd=i_srec.dpt_cd and div_cd=i_srec.div_cd;
                    -- mig_logger.write_log('D7Z004',i_mrec.XXXXX,'DUMMY');
                    -- select name into a_lab_name from lab        where fac_cd=i_srec.fac_cd and dpt_cd=i_srec.dpt_cd and div_cd=i_srec.div_cd and lab_cd=i_srec.lab_cd;
                    -- mig_logger.write_log('D7Z005',i_mrec.XXXXX,'DUMMY');
                    --select fac_name,dpt_name,div_name,lab_name into a_fac_name,a_dpt_name,a_div_name,a_lab_name from MIG_STUDENT_ALL_LIST where stu_idx=i_mrec.XXXXX;
                    -- mig_logger.write_log('D7Z006',i_mrec.XXXXX,'DUMMY');
                    
                    a_fac_name:=nvl(a_fac_name,'DUMMY');
                    a_dpt_name:=nvl(a_dpt_name,'DUMMY');
                    a_div_name:=nvl(a_div_name,'DUMMY');
                    a_lab_name:=nvl(a_lab_name,'DUMMY');
                    
                    mig_logger.write_log('D7Z010',i_mrec.XXXXX,
                    '[a_stu_cd_header=]'||a_stu_cd_header||
                    '[a_fac_name=]'||nvl(a_fac_name,'NULL')||
                    '[a_dpt_name=]'||nvl(a_dpt_name,'NULL')||
                    '[a_div_name=]'||nvl(a_div_name,'NULL')||
                    '[a_lab_name=]'||nvl(a_lab_name,'NULL'));
                    
                    if(--a_fac_name like '%XXXXX%' 
                    --or
                    a_dpt_name like '%XXXXX%' 
                    --or a_div_name like '%XXXXX%' 
                    --or a_lab_name like '%XXXXX%' 
                    )
                        then a_out_cd := '71'; -- 'Course students[XXXXX]'
                    elsif
                      (--a_fac_name like '%Inspection%' 
                    --or
                     a_dpt_name like '%Inspection%' 
                    --or a_div_name like '%Inspection%' 
                    --or a_lab_name like '%Inspection%' 
                    )
                        then a_out_cd := '72'; -- 'Course students[Inspection]'
                    else
                             a_out_cd := '7Z'; -- 'Course students(Unknown)'
                    end if;
                    --a_out_cd := '7Z'; -- 'Course students(Unknown)'
                end if;
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 17 From old code to  74 from XXXXX to  98(Graduate student31[ treat as ]/10 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='74' and a_stu_div_cd_by_scd_fac='98')
                then
                mig_logger.write_log('DPTRN17',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '21'; -- 'Graduate student'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 18 From old code to  96 from XXXXX to  98(Special Auditing Students49[ treat as ]/24 number(s)
            elsif(a_stu_div_cd_by_kti_kubun='96' and a_stu_div_cd_by_scd_fac='98')
                then
                mig_logger.write_log('DPTRN18',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '49'; -- 'Special Auditing Students'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            -- Pattern 19 from XXXXX to  98(Special Auditing Students[A certain company]61[ treat as ]/20 number(s)
            elsif(a_stu_div_cd_by_scd_fac='61')
                then
                mig_logger.write_log('DPTRN19',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                a_out_cd := '61'; -- 'Special Auditing Students[A certain company]61'
                --o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;

            else
                a_out_cd:='98';--Unknown
                mig_logger.write_log('DPTRN??',i_mrec.XXXXX,' [XXXXX]'||a_out_cd||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
                o_note   := '[XXXXX System Automatic grant/number][XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||i_mrec.XXXXX||'[XXXXX=]'||a_out_cd;
            end if;
            mig_logger.write_log('DCHKD',i_mrec.XXXXX,' [XXXXX]'||LPAD(NVL(a_out_cd,' '),2,' ')||' [XXXXX]'||a_stu_div_cd_by_kti_kubun||' [XXXXX]'||a_stu_div_cd_by_scd_fac);
        end if;
    return a_out_cd;
    end;
    
/* [No doc] Processing based on the meeting on YYYY.9.18
/* NOTE:XXXXX judge by first two characters and new faculty codes
/* from XXXXX to  */
    function get_stu_div_cd_by_scd_fac(
        i_stu_cd_header      in     varchar2, --> XXXXX[First two characters]
        i_stu_cd_5th         in     varchar2, --> XXXXX[5th character of]
        i_stu_cd_6th         in     varchar2, --> XXXXX[6th character of]
        i_fac_cd             in     varchar2  --> Faculty code

    )return varchar2
    is
        a_out_cd varchar2(2);
    begin
        /* A.graduate School(Regular)[MDB.M_DOCTOR.XXXXX=1 ] */
        /*42*/
          if   (i_stu_cd_header='42')then a_out_cd := '11'; --Medical and Dental Science GraduateCourse SomeCourseTypeXX MajorMasterXXXXX  -- graduate Schoolê∂ MasterXXXXX
        /*43*/
          elsif(i_stu_cd_header='43')then                   --Medical and Dental Science GraduateCourse XXX MajorDoctorXXXXX    -- graduate Schoolê∂ DoctorXXXXX
            if   (i_fac_cd='21') then  a_out_cd := '11';    --MasterXXXXX              before restructuring([impossible])
            elsif(i_fac_cd='22') then  a_out_cd := '15';    --DoctorXXXXX         4 years  before restructuring
            elsif(i_fac_cd='31') then  a_out_cd := '11';    --MasterXXXXX              after restructuring([impossible])
            elsif(i_fac_cd='36') then  a_out_cd := '14';    --DoctorXXXXX         3 years  after restructuring
            elsif(i_fac_cd='41') then  a_out_cd := '15';    --DoctorXXXXX         4 years  after restructuring
            else                       a_out_cd := '98';
            end if;
        /*47*/
          elsif(i_stu_cd_header='47')then                   --Medical and Dental Science GraduateCourseMajorDoctorXXXXX    -- graduate Schoolê∂ DoctorXXXXX
            if   (i_fac_cd='21') then  a_out_cd := '11';    --MasterXXXXX              before restructuring([impossible])
            elsif(i_fac_cd='22') then  a_out_cd := '15';    --DoctorXXXXX         4 years  before restructuring
            elsif(i_fac_cd='31') then  a_out_cd := '11';    --MasterXXXXX              after restructuring([impossible])
            elsif(i_fac_cd='36') then  a_out_cd := '14';    --DoctorXXXXX         3 years  after restructuring
            elsif(i_fac_cd='41') then  a_out_cd := '15';    --DoctorXXXXX         4 years  after restructuring
            else                       a_out_cd := '98';
            end if;
          elsif(i_stu_cd_header='20')then a_out_cd := '16'; --XXX
          elsif(i_stu_cd_header='23')then a_out_cd := '12'; --XXX
          elsif(i_stu_cd_header='24')then a_out_cd := '12'; --XXX
          elsif(i_stu_cd_header='25')then a_out_cd := '16'; --XXX
          elsif(i_stu_cd_header='26')then a_out_cd := '13'; --XXX
          elsif(i_stu_cd_header='27')then a_out_cd := '13'; --XXX
          elsif(i_stu_cd_header='45')then a_out_cd := '11'; --MMA
          elsif(i_stu_cd_header='46')then a_out_cd := '11'; --MMA
        /* B.Non-Regular */
           /* B-1.XXXXX[MDB.M_DOCTOR.XXXXX=2] */
          elsif(i_stu_cd_header='48')then a_out_cd := '21'; -- XXXXX(Medical and Dental Science GraduateCourse)
          elsif(i_stu_cd_header='28' and i_stu_cd_5th='1')
                                     then a_out_cd := '21'; -- XXXXX(XXXGraduateCourse)
          /* B-2.Special Auditing Students[MDB.M_DOCTOR.XXXXX=3] */
          elsif(i_stu_cd_header='40')then a_out_cd := '44'; --([doesnt exist])Special Auditing Students(Medical and Dental Science GraduateCourse)
          elsif(i_stu_cd_header='28' and i_stu_cd_5th='2')
                                     then a_out_cd := '4Y'; -- Special Auditing Students(XXXGraduateCourse)
          /* B-3.Graduate student[MDB.M_DOCTOR.XXXXX=4] */
          elsif(i_stu_cd_header='71' and i_stu_cd_5th='5')
                                     then a_out_cd := '31'; -- Graduate student
          elsif(i_stu_cd_header='71' and i_stu_cd_5th='7')
                                     then a_out_cd := '32'; -- Graduate student[graduate School Short term  Research student ]
          /* B-4.Course students[MDB.M_DOCTOR.XXXXX=5] */
          elsif(i_stu_cd_header='29')then a_out_cd := '7Y'; --XXXGraduateCourseCourse students
          elsif(i_stu_cd_header='30')then a_out_cd := '73'; --XXXXXProfessionalCourse students
          /* B-5.Course students[MDB.M_DOCTOR.XXXXX=6] */
          elsif(i_stu_cd_header='71' and i_stu_cd_5th='0' and i_stu_cd_6th='9')
                                     then a_out_cd := '33'; --Graduate student[A certain companygraduate School special  Research student ]
          elsif(i_stu_cd_header='72' and i_stu_cd_5th='0' and i_stu_cd_6th='9')
                                     then a_out_cd := '61'; -- Auditor [A certain companygraduate School special  Auditor ]
          else                            a_out_cd := '98';
          end if;
    return a_out_cd;
    end;

    function get_stu_div_cd_by_kti_kubun(
        i_process              in     varchar2, --> XXXXX
        i_student_kubun      in     number    --> XXXXX
    )return varchar2
    is
        a_process  varchar2(2);
        a_out_cd varchar2(2);
    begin
    
        a_process:=i_process;
        
        -- 
        if   (a_process='1') then a_process:= '01';
        elsif(a_process='2') then a_process:= '02';
        elsif(a_process='3') then a_process:= '03';
        elsif(a_process='4') then a_process:= '04';
        elsif(a_process='5') then a_process:= '05';
        elsif(a_process='6') then a_process:= '06';
        elsif(a_process='7') then a_process:= '07';
        elsif(a_process='8') then a_process:= '08';
        elsif(a_process='9') then a_process:= '09';
        end if;
    
        case a_process
            when '01' then -- MasterXXXXX
                case i_student_kubun
                    when 1 then a_out_cd:='11';-- StudentTypeGeneral
                    when 2 then a_out_cd:='11';-- 
                    when 3 then a_out_cd:='79';-- Course students(Which Course studentsor Unknown Confirmation required)
                    when 4 then a_out_cd:='31';-- Graduate studentÅ@Å©A certain company[Not included]
                    when 5 then a_out_cd:='21';-- XXXXX
                    when 6 then a_out_cd:='49';-- Special Auditing StudentsÅ@Å©A certain company[Not included](Which Special Auditing Studentsor Unknown Confirmation required)
                    when 7 then a_out_cd:='96';--  Auditor Å@Å©A certain company[Not included](Which  Auditor or Unknown Confirmation required)
                    when 8 then a_out_cd:='33';-- Graduate student(A certain companygraduate School special  Research student )
                    when 9 then a_out_cd:='61';--  Auditor (A certain companygraduate School special  Auditor )
                    when 10 then a_out_cd:='32';-- Graduate student(graduate School Short term  Research student )
                    else        a_out_cd:='98';-- Unknown
                end case;
            when '02' then -- DoctorXXXXX( 4 years)
                case i_student_kubun
                    when 1 then a_out_cd:='15';-- Regular
                    when 2 then a_out_cd:='15';-- Unknown(XXXXX=2)
                    when 3 then a_out_cd:='79';-- Course students(Which Course studentsor Unknown Confirmation required)
                    when 4 then a_out_cd:='31';-- Graduate studentÅ@Å©A certain company[Not included]
                    when 5 then a_out_cd:='21';-- XXXXX
                    when 6 then a_out_cd:='49';-- Special Auditing StudentsÅ@Å©A certain company[Not included](Which Special Auditing Studentsor Unknown Confirmation required)
                    when 7 then a_out_cd:='96';--  Auditor Å@Å©A certain company[Not included](Which  Auditor or Unknown Confirmation required)
                    when 8 then a_out_cd:='33';-- Graduate student(A certain companygraduate School special  Research student )
                    when 9 then a_out_cd:='61';--  Auditor (A certain companygraduate School special  Auditor )
                    when 10 then a_out_cd:='32';-- Graduate student(graduate School Short term  Research student )
                    else        a_out_cd:='98';-- Unknown
                end case;
            when '03' then -- DoctorXXXXX[Previous term]
                case i_student_kubun
                    when 1 then a_out_cd:='12';-- Regular
                    when 2 then a_out_cd:='12';-- Unknown(XXXXX=2)
                    when 3 then a_out_cd:='79';-- Course students(Which Course studentsor Unknown Confirmation required)
                    when 4 then a_out_cd:='31';-- Graduate studentÅ@Å©A certain company[Not included]
                    when 5 then a_out_cd:='21';-- XXXXX
                    when 6 then a_out_cd:='49';-- Special Auditing StudentsÅ@Å©A certain company[Not included](Which Special Auditing Studentsor Unknown Confirmation required)
                    when 7 then a_out_cd:='96';--  Auditor Å@Å©A certain company[Not included](Which  Auditor or Unknown Confirmation required)
                    when 8 then a_out_cd:='33';-- Graduate student(A certain companygraduate School special  Research student )
                    when 9 then a_out_cd:='61';--  Auditor (A certain companygraduate School special  Auditor )
                    when 10 then a_out_cd:='32';-- Graduate student(graduate School Short term  Research student )
                    else        a_out_cd:='98';-- Unknown
                end case;
            when '04' then -- DoctorXXXXX[Latter term]
                case i_student_kubun
                    when 1 then a_out_cd:='13';-- Regular
                    when 2 then a_out_cd:='13';-- Unknown(XXXXX=2)
                    when 3 then a_out_cd:='79';-- Course students(Which Course studentsor Unknown Confirmation required)
                    when 4 then a_out_cd:='31';-- Graduate studentÅ@Å©A certain company[Not included]
                    when 5 then a_out_cd:='21';-- XXXXX
                    when 6 then a_out_cd:='49';-- Special Auditing StudentsÅ@Å©A certain company[Not included](Which Special Auditing Studentsor Unknown Confirmation required)
                    when 7 then a_out_cd:='96';--  Auditor Å@Å©A certain company[Not included](Which  Auditor or Unknown Confirmation required)
                    when 8 then a_out_cd:='33';-- Graduate student(A certain companygraduate School special  Research student )
                    when 9 then a_out_cd:='61';--  Auditor (A certain companygraduate School special  Auditor )
                    when 10 then a_out_cd:='32';-- Graduate student(graduate School Short term  Research student )
                    else        a_out_cd:='98';-- Unknown
                end case;
            when '05' then -- DoctorXXXXX( 3 years)
                case i_student_kubun
                    when 1 then a_out_cd:='14';-- Regular
                    when 2 then a_out_cd:='14';-- Unknown(XXXXX=2)
                    when 3 then a_out_cd:='79';-- Course students(Which Course studentsor Unknown Confirmation required)
                    when 4 then a_out_cd:='31';-- Graduate studentÅ@Å©A certain company[Not included]
                    when 5 then a_out_cd:='21';-- XXXXX
                    when 6 then a_out_cd:='49';-- Special Auditing StudentsÅ@Å©A certain company[Not included](Which Special Auditing Studentsor Unknown Confirmation required)
                    when 7 then a_out_cd:='96';--  Auditor Å@Å©A certain company[Not included](Which  Auditor or Unknown Confirmation required)
                    when 8 then a_out_cd:='33';-- Graduate student(A certain companygraduate School special  Research student )
                    when 9 then a_out_cd:='61';--  Auditor (A certain companygraduate School special  Auditor )
                    when 10 then a_out_cd:='32';-- Graduate student(graduate School Short term  Research student )
                    else        a_out_cd:='98';-- Unknown
                end case;
            when '09' then -- Graduate student
                case i_student_kubun
                    when 1 then a_out_cd:='31';-- Regular
                    when 2 then a_out_cd:='92';-- Unknown(XXXXX=2)
                    when 3 then a_out_cd:='79';-- Course students(Which Course studentsor Unknown Confirmation required)
                    when 4 then a_out_cd:='31';-- Graduate studentÅ@Å©A certain company[Not included]
                    when 5 then a_out_cd:='21';-- XXXXX
                    when 6 then a_out_cd:='49';-- Special Auditing StudentsÅ@Å©A certain company[Not included](Which Special Auditing Studentsor Unknown Confirmation required)
                    when 7 then a_out_cd:='96';--  Auditor Å@Å©A certain company[Not included](Which  Auditor or Unknown Confirmation required)
                    when 8 then a_out_cd:='33';-- Graduate student(A certain companygraduate School special  Research student )
                    when 9 then a_out_cd:='61';--  Auditor (A certain companygraduate School special  Auditor )
                    when 10 then a_out_cd:='32';-- Graduate student(graduate School Short term  Research student )
                    else        a_out_cd:='98';-- Unknown
                end case;
            when '10' then -- DoctorXXXXX( 5 years )
                case i_student_kubun
                    when 1 then a_out_cd:='16';-- Regular
                    when 2 then a_out_cd:='16';-- Unknown(XXXXX=2)
                    when 3 then a_out_cd:='79';-- Course students(Which Course studentsor Unknown Confirmation required)
                    when 4 then a_out_cd:='31';-- Graduate studentÅ@Å©A certain company[Not included]
                    when 5 then a_out_cd:='21';-- XXXXX
                    when 6 then a_out_cd:='49';-- Special Auditing StudentsÅ@Å©A certain company[Not included](Which Special Auditing Studentsor Unknown Confirmation required)
                    when 7 then a_out_cd:='96';--  Auditor Å@Å©A certain company[Not included](Which  Auditor or Unknown Confirmation required)
                    when 8 then a_out_cd:='33';-- Graduate student(A certain companygraduate School special  Research student )
                    when 9 then a_out_cd:='61';--  Auditor (A certain companygraduate School special  Auditor )
                    when 10 then a_out_cd:='32';-- Graduate student(graduate School Short term  Research student )
                    else        a_out_cd:='98';-- Unknown
                end case;
            else           a_out_cd:='98';-- Unknown
        end case;
        
        --XXXXX=NULL
        if(a_process is null)then
                case i_student_kubun
                    --when 1 then a_out_cd:='16';-- Regular
                    --when 2 then a_out_cd:='92';-- Unknown(XXXXX=2)
                    when 3 then a_out_cd:='79';-- Course students(Unknown)
                    when 4 then a_out_cd:='39';-- Graduate student(Unknown)
                    when 5 then a_out_cd:='21';-- XXXXX(Unknown)
                    when 6 then a_out_cd:='96';-- Special Auditing Students
                    else        a_out_cd:='98';-- Unknown
                end case;
        end if;

        
        return a_out_cd;
    end;



/*MajorÅÀDepartment*/
    procedure get_fac_dpt_cd(
        i_mrec             in     mdb.m_doctor%rowtype,   --> MDB.M_DOCTOR type record(s)
        o_fac_cd           out    varchar2,               --< Faculty code
        o_dpt_cd           out    varchar2,               --< Department code(s)
        o_txt              out    varchar2                --< 
    )
    is
        a_stu_cd_header          varchar2(2); 
        a_stu_cd_5th_ch          varchar2(1); 
        a_stu_cd_6th_ch          varchar2(1); 
        
        a_process                 varchar2(100);
    begin
        /* îªíËópïœêî */
        a_stu_cd_header := substr(i_mrec.XXXXX,1,2);
        a_stu_cd_5th_ch := substr(i_mrec.XXXXX,5,1);
        a_stu_cd_6th_ch := substr(i_mrec.XXXXX,6,1);

        if   (i_mrec.GraduateCourse='02'and i_mrec.Major='01')
            then 
                if   (mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]')
                    then o_fac_cd := '23';o_dpt_cd := '01';                                       --XXXGraduateCourse Doctor[Pre
                elsif(mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]')
                    then o_fac_cd := '24';o_dpt_cd := '01';                                       --XXXGraduateCourse Doctor[Lat
                else 
                    MIG_LOGGER.write_log('E03-2X',i_mrec.XXXXX,'[Doc  No.03-2]GraduateCourse,Major[doesn't match] '||i_mrec.GraduateCourse||' '||i_mrec.Major||' '||i_mrec.MiddleCourse||' '||i_mrec.FieldArea||' i_mrec.XXX='||i_mrec.XXX||' mig_lib.get_period_from_stu_cd_header(a_stu_cd_header)='||mig_lib.get_period_from_stu_cd_header(i_mrec.XXX));
                    o_fac_cd := '29';o_dpt_cd := '01';                                       --XXXGraduateCourse Unknown       
                end if;
        elsif(i_mrec.GraduateCourse='02'and i_mrec.Major='02')
            then
                if   (mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]'/**/)
                    then o_fac_cd := '51';o_dpt_cd := '01';                                       --XXXGraduateCourse Doctor[Prev
                elsif(mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]'/**/)
                    then o_fac_cd := '56';o_dpt_cd := '01';                                       --XXXGraduateCourse Doctor[Latt
                else
                    MIG_LOGGER.write_log('E03-5X',i_mrec.XXXXX,'[No.03-2]GraduateCourse,Major[doesn't match] '||i_mrec.GraduateCourse||' '||i_mrec.Major||' '||i_mrec.MiddleCourse||' '||i_mrec.FieldArea||' i_mrec.XXX='||i_mrec.XXX||' mig_lib.get_period_from_stu_cd_header(a_stu_cd_header)='||mig_lib.get_period_from_stu_cd_header(i_mrec.XXX));
                    o_fac_cd := '59';o_dpt_cd := '01';                                       --XXXGraduateCourse Unknown        /InspectionMajor
                end if;
        elsif(i_mrec.GraduateCourse='02'and i_mrec.Major='03')
            then o_fac_cd := '61';o_dpt_cd := '01';                                               --XXXGraduateCourse Doctor( 5 years )/XXXXXMajor
        elsif(i_mrec.GraduateCourse='02'and i_mrec.Major='04')
            then o_fac_cd := '61';o_dpt_cd := '06';                                       --XXXGraduateCourse Doctor( 5 years )/XXXXXXXX
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='00')
            then o_fac_cd := '21';o_dpt_cd := '01';                                       --Medical and Dental Science GraduateCourse Master/XXXXXX
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='01')
            then o_fac_cd := '22';o_dpt_cd := '01';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='02')
            then o_fac_cd := '22';o_dpt_cd := '02';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='03')
            then o_fac_cd := '22';o_dpt_cd := '03';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='04')
            then o_fac_cd := '22';o_dpt_cd := '04';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='05')
            then o_fac_cd := '22';o_dpt_cd := '05';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='06')
            then o_fac_cd := '22';o_dpt_cd := '06';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='07')
            then o_fac_cd := '22';o_dpt_cd := '07';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='08')
            then o_fac_cd := '22';o_dpt_cd := '08';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='09')
            then o_fac_cd := '22';o_dpt_cd := '09';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='10')
            then o_fac_cd := '22';o_dpt_cd := '10';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='11')
            then o_fac_cd := '31';o_dpt_cd := '01';                                       --Medical and Dental Science GraduateCourse Master/
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='12')
            then o_fac_cd := '41';o_dpt_cd := '01';                                       --Medical and Dental Science GraduateCourse Doctor( 4 yea
        elsif(i_mrec.GraduateCourse='04'and i_mrec.Major='13')
            then o_fac_cd := '36';o_dpt_cd := '01';                                       --Medical and Dental Science GraduateCourse Doctor( 3 yea
        elsif(i_mrec.GraduateCourse='06'and i_mrec.Major='01')
            then
                if   (mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]')
                    then o_fac_cd := '25';o_dpt_cd := '01';                               --XXXGraduateCourse Doctor[Previous term]/Major
                  elsif(mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]')
                    then o_fac_cd := '26';o_dpt_cd := '01';                               --XXXGraduateCourse Doctor[Latter term]/Major
                  else
                    MIG_LOGGER.write_log('E03-2Y',i_mrec.XXXXX,'[Doc  No.03-2]GraduateCourse,Major[doesn't match] '||i_mrec.GraduateCourse||' '||i_mrec.Major||' '||i_mrec.MiddleCourse||' '||i_mrec.FieldArea||' i_mrec.XXX='||i_mrec.XXX||' mig_lib.get_period_from_stu_cd_header(a_stu_cd_header)='||mig_lib.get_period_from_stu_cd_header(i_mrec.XXX));
                    o_fac_cd := '28';o_dpt_cd := '01';                               --XXXGraduateCourse Unknown        /Major
                end if;
        elsif(i_mrec.GraduateCourse='06'and i_mrec.Major='02')
            then 
                if   (mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]')
                    then o_fac_cd := '25';o_dpt_cd := '02';                               --XXXGraduateCourse Doctor[Previous term]/Major
                  elsif(mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]')
                    then o_fac_cd := '26';o_dpt_cd := '02';                               --XXXGraduateCourse Doctor[Latter term]/Major
                else
                    MIG_LOGGER.write_log('E03-2Z',i_mrec.XXXXX,'[Doc  No.03-2]GraduateCourse,Major[doesn't match] '||i_mrec.GraduateCourse||' '||i_mrec.Major||' '||i_mrec.MiddleCourse||' '||i_mrec.FieldArea||' i_mrec.XXX='||i_mrec.XXX||' mig_lib.get_period_from_stu_cd_header(a_stu_cd_header)='||mig_lib.get_period_from_stu_cd_header(i_mrec.XXX));
                    o_fac_cd := '29';o_dpt_cd := '02';                               --XXXGraduateCourse Unknown        /Major
                end if;
        else
            if   (i_mrec.GraduateCourse='02')
              then o_fac_cd := '92';                                                        --Unknown(02) 
            elsif(i_mrec.GraduateCourse='04')
              then o_fac_cd := '94';                                                        --Unknown(04) 
            elsif(i_mrec.GraduateCourse='06')
              then o_fac_cd := '96';                                                        --Unknown(06) 
            else
               o_fac_cd := '98';                                                        --Unknown
            end if;
            MIG_LOGGER.write_log('E03-98',i_mrec.XXXXX,'[Doc  No.03-2]GraduateCourse,Major[doesn\'t match] '||i_mrec.GraduateCourse||' '||i_mrec.Major||' '||i_mrec.MiddleCourse||' '||i_mrec.FieldArea||' i_mrec.XXX='||i_mrec.XXX||' mig_lib.get_period_from_stu_cd_header(a_stu_cd_header)='||mig_lib.get_period_from_stu_cd_header(i_mrec.XXX));
            o_txt:='[DestinationMajor(Department)Unknown]'||'[OldGraduateCourse=]'||i_mrec.GraduateCourse||''[OldMajor=]'||i_mrec.Major;
        end if;
    end;


    procedure get_fac_dpt_div_cd(
        i_mrec             in     mdb.m_doctor%rowtype,   --> MDB.M_DOCTOR type record(s)
        o_fac_cd           out    varchar2,               --< Faculty code
        o_dpt_cd           out    varchar2,               --< Department code(s)
        o_div_cd           out    varchar2,                --< Course code(s)
        o_txt              out    varchar2                --< 
    )
    is
       a_stu_cd_header          varchar2(2); 
   begin
       a_stu_cd_header := substr(i_mrec.XXXXX,1,2);
       if(false) then
         null;
         /* START of aotomatically generate source */
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='15' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='15' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='33' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='33' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';--
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='03' and i_mrec.MiddleCourse='51') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='03' and i_mrec.MiddleCourse='52') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';-
        elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='03' and i_mrec.MiddleCourse='53') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '11';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='00' and i_mrec.MiddleCourse='00') then o_fac_cd:= '21';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='00' and i_mrec.MiddleCourse='01') then o_fac_cd:= '21';o_dpt_cd:= '01';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='00' and i_mrec.MiddleCourse='02') then o_fac_cd:= '21';o_dpt_cd:= '01';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='03') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '03';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='04') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '04';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='03') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '03';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='12') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='01') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '06';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='06') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '21';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='15') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '21';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';--
        elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';-
        elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';--
        else
          if(i_mrec.MiddleCourse is not null) then
              o_div_cd:='99';--ïsàÍív
              MIG_LOGGER.write_log('E03-4',i_mrec.XXXXX,'[Doc  No.03-3]GraduateCourse,Major,MiddleCourse[doesn't match] '||i_mrec.GraduateCourse||' '||i_mrec.Major||' '||i_mrec.MiddleCourse||' '||i_mrec.FieldArea||' i_mrec.XXX='||i_mrec.XXX||' mig_lib.get_period_from_stu_cd_header(a_stu_cd_header)='||mig_lib.get_period_from_stu_cd_header(i_mrec.XXX));
              o_txt:='[DestinationMiddleCourse(Course)Unknown]'||'[OldGraduateCourse=]'||i_mrec.GraduateCourse||'[OldMajor=]'||i_mrec.Major||'[OldMiddleCourse=]'||i_mrec.MiddleCourse;
          end if;
        end if;
    end;

    procedure get_fac_dpt_div_lab_cd(
        i_mrec             in     mdb.m_doctor%rowtype,   --> MDB.M_DOCTOR type record(s)
        o_fac_cd           out    varchar2,               --< Faculty code
        o_dpt_cd           out    varchar2,               --< Department code(s)
        o_div_cd           out    varchar2,               --< Course code(s)
        o_lab_cd           out    varchar2,               --< Field/Area code(s)
        o_txt              out    varchar2                --< ÉeÉLÉXÉg
   )
   is
        a_stu_cd_header          varchar2(2); 
   begin
        a_stu_cd_header := substr(i_mrec.XXXXX,1,2);
       if(false) then
         null;
        /* Automatically generated source section START */
        
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ínàÊ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ínàÊï€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç›ëÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç›ëÓÉP
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÿÃﬂ€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÿÃﬂ€¿ﬁ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ê∏ê_
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ê∏ê_ï€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0001';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0001';--LivingBodyÅE
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';--è¨éô
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';--è¨éôÅE
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0021';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0021';--êÊí[êN
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0031';--çÇóÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0031';--çÇóÓé“
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0041';--XXXX
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0041';--XXXXXº
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0001';--åíçN
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0001';--åíçNèÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0011';--åíçN
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0011';--åíçNã≥
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0021';--çëç€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0021';--çëç€XX
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='5001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ínàÊ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='5001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ínàÊï€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='5002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç›ëÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='5002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç›ëÓÉP
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='5003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉäÉv
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='5003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉäÉvÉç
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='5004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ê∏ê_
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='5004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ê∏ê_ï€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0001';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0001';--LivingBodyÅE
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5006' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';--è¨éô
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5006' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';--è¨éôÅE
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0021';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0021';--êÊí[êN
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5008' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0031';--çÇóÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5008' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0031';--çÇóÓé“
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0041';--XXXX
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='5009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0041';--XXXXX 
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='15' and i_mrec.FieldArea='5010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0001';--åíçN
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='15' and i_mrec.FieldArea='5010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0001';--åíçNèÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='15' and i_mrec.FieldArea='5011' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0011';--åíçN
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='15' and i_mrec.FieldArea='5011' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0011';--åíçNã≥
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='15' and i_mrec.FieldArea='5012' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0021';--çëç€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='15' and i_mrec.FieldArea='5012' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0021';--çëç€XX
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and i_mrec.FieldArea='6010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ínàÊ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and i_mrec.FieldArea='6010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ínàÊï€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and i_mrec.FieldArea='6020' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç›ëÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and i_mrec.FieldArea='6020' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç›ëÓÉP
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and i_mrec.FieldArea='6030' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉäÉv
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and i_mrec.FieldArea='6030' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉäÉvÉç
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and i_mrec.FieldArea='6040' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ê∏ê_
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='31' and i_mrec.FieldArea='6040' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ê∏ê_ï€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6050' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0001';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6050' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0001';--LivingBodyÅE
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6060' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';--è¨éô
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6060' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';--è¨éôÅE
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6070' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0021';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6070' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0021';--êÊí[êN
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6080' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0031';--çÇóÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6080' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0031';--çÇóÓé“
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6090' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0041';--XXXX
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='32' and i_mrec.FieldArea='6090' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0041';--XXXXX 
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='33' and i_mrec.FieldArea='6100' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0001';--åíçN
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='33' and i_mrec.FieldArea='6100' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0001';--åíçNèÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='33' and i_mrec.FieldArea='6110' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0011';--åíçN
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='33' and i_mrec.FieldArea='6110' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0011';--åíçNã≥
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='33' and i_mrec.FieldArea='6120' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0021';--çëç€
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='01' and i_mrec.MiddleCourse='33' and i_mrec.FieldArea='6120' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '24';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0021';--çëç€XX
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ï™éq
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ï™éqê∂
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--å`ë‘
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--å`ë‘ÅE
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ê∂ñΩã@
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--LivingBodyã@
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0032';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0032';--LivingBodyã@
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--éæä≥Area
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--éæä≥ÉÇea
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';--êÊí[èÓ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0002';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0002';--êÊí[ï™
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--LivingBodyñh
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0021';--ï™éq
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0021';--ï™éqïa
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0031';--à‚ì`
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0031';--à‚ì`éq
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0032';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0032';--êÊí[åå
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0041';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0041';--êÊí[ê∂
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='6001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ï™éq
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='6001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ï™éqê∂
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='6002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--å`ë‘
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='6002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--å`ë‘ÅE
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='6003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='6003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ê∂ñΩã@
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='6004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0032';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='6004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0032';--LivingBodyã@
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0002';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0002';--êÊí[ï™
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6006' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6006' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--LivingBodyñh
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0021';--ï™éq
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0021';--ï™éqïa
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6008' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0032';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6008' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0032';--êÊí[åå
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0042';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='6009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0042';--êÊí[ê∂
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and i_mrec.FieldArea='7010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ï™éq
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and i_mrec.FieldArea='7010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ï™éqê∂
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and i_mrec.FieldArea='7020' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--å`ë‘
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and i_mrec.FieldArea='7020' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--å`ë‘ÅE
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and i_mrec.FieldArea='7030' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and i_mrec.FieldArea='7030' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ê∂ñΩã@
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and i_mrec.FieldArea='7040' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0032';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='41' and i_mrec.FieldArea='7040' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0032';--LivingBodyã@
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7050' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0002';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7050' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0002';--êÊí[ï™
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7060' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--LivingBody
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7060' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--LivingBodyñh
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7070' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0021';--ï™éq
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7070' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0021';--ï™éqïa
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7080' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0032';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7080' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0032';--êÊí[åå
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7090' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0042';--êÊí[
       elsif(i_mrec.GraduateCourse='02' and i_mrec.Major='02' and i_mrec.MiddleCourse='42' and i_mrec.FieldArea='7090' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '56';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0042';--êÊí[ê∂

       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='00' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0001') then o_fac_cd:= '21';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0001';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='00' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0001') then o_fac_cd:= '21';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='00' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0002') then o_fac_cd:= '21';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0002';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0012';--ç◊ã€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0402') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0032';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0502') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0042';--ä{å˚
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0701') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ñÉêå
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0801') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0071';--·uí…
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0901') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0081';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0001';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0002';--è¨éô
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';--ô˘çá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0012';--ô˘çá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0031';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0001';--Ç§êI
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0011';--ê€êH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0021';--éïêë
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0041';--óLã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0051';--Functions
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0701') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0032';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '04';o_lab_cd:= '0001';--ê€êH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '04';o_lab_cd:= '0002';--ïîï™
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '04';o_lab_cd:= '0011';--ê€êH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '04';o_lab_cd:= '0012';--≤›Ãﬂ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '04';o_lab_cd:= '0021';--ÉCÉì
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '04';o_lab_cd:= '0031';--ê€êH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='01' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='0402') then o_fac_cd:= '22';o_dpt_cd:= '01';o_div_cd:= '04';o_lab_cd:= '0032';--ëSïî
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0011';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0012';--îFím
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0031';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0041';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '02';o_lab_cd:= '0001';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '02';o_lab_cd:= '0011';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '02';o_lab_cd:= '0021';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '02';o_lab_cd:= '0031';--è·äQ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '02';o_lab_cd:= '0041';--ã‡ëÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '02';o_lab_cd:= '0051';--ã@äB
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '03';o_lab_cd:= '0001';--Functions
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '03';o_lab_cd:= '0002';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '03';o_lab_cd:= '0011';--å`ê¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '03';o_lab_cd:= '0021';--ì™ËÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='02' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '02';o_div_cd:= '03';o_lab_cd:= '0031';--éÓ·á
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '01';o_lab_cd:= '0001';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '01';o_lab_cd:= '0011';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '01';o_lab_cd:= '0021';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '01';o_lab_cd:= '0031';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '01';o_lab_cd:= '0041';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '01';o_lab_cd:= '0051';--éïé¸
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0701') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '01';o_lab_cd:= '0061';--ñ≥ã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '02';o_lab_cd:= '0001';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '02';o_lab_cd:= '0002';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '02';o_lab_cd:= '0011';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '02';o_lab_cd:= '0021';--â^ìÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '03';o_div_cd:= '02';o_lab_cd:= '0022';--â^ìÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4004') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4008') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0241';--ënñÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4010') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0201';--ñ≥ã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4019') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0141';--çÇéü
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4021') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0221';--é°ó√
       --deleted elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4026') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--Ç®íÉ
       --deleted elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4027') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ñkó¢
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='03' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='404') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0001';--åíçN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0011';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0021';--éiñ@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0031';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0041';--åíçN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0051';--ÉXÉ|
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0701') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0061';--ñ@éï
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0801') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0071';--é–âÔ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0802') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0072';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0901') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0081';--âuäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0902') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0082';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='1001') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '01';o_lab_cd:= '0091';--êÊêi
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0001';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0002';--ê≠çÙ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0011';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0021';--à„éï
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0022';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0031';--à„éï
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0402') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0032';--å§ãÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0041';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0602') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0051';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0701') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0061';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='04' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0801') then o_fac_cd:= '22';o_dpt_cd:= '04';o_div_cd:= '02';o_lab_cd:= '0071';--ã≥àÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '01';o_lab_cd:= '0001';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '01';o_lab_cd:= '0002';--çÇóÓ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0001';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0002';--ïÔäá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0011';--òVîN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0012';--ìùçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0021';--ååó¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0031';--ååó¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0402') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0032';--ååä«
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0403') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0033';--êHìπ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0051';--ÿ Àﬁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='05' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '05';o_div_cd:= '02';o_lab_cd:= '0041';--åƒãz
       --deleted elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '01';o_lab_cd:= '0001';--Synthesis
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '01';o_lab_cd:= '0011';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '01';o_lab_cd:= '0012';--ì™ËÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0203') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '01';o_lab_cd:= '0013';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '01';o_lab_cd:= '0021';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '01';o_lab_cd:= '0031';--ä{ä÷
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '02';o_lab_cd:= '0001';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '02';o_lab_cd:= '0011';--ã~ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '02';o_lab_cd:= '0021';--êSó√
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '02';o_lab_cd:= '0022';--êSó√
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '02';o_lab_cd:= '0031';--ñÚï®
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '02';o_lab_cd:= '0041';--Synthesis
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0502') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '02';o_lab_cd:= '0042';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='06' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '06';o_div_cd:= '02';o_lab_cd:= '0051';--ã~ã}
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0001';--íÜêï
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0002';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0103') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0003';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0011';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0012';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0021';--éãäo
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0022';--ä·â»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0031';--íÆïΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0402') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0032';--é®ï@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0041';--îFím
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0051';--çsìÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0602') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '01';o_lab_cd:= '0052';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '02';o_lab_cd:= '0001';--çÇéü
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '02';o_lab_cd:= '0002';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '02';o_lab_cd:= '0011';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '02';o_lab_cd:= '0012';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '02';o_lab_cd:= '0021';--ê∏ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '02';o_lab_cd:= '0031';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '02';o_lab_cd:= '0051';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='07' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '07';o_div_cd:= '02';o_lab_cd:= '0041';--ååä«
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';o_lab_cd:= '0001';--ä¥êı
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';o_lab_cd:= '0002';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';o_lab_cd:= '0011';--ÉEÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';o_lab_cd:= '0021';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';o_lab_cd:= '0031';--éÓ·á
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0402') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';o_lab_cd:= '0032';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0403') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';o_lab_cd:= '0033';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';o_lab_cd:= '0041';--ÉEÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0502') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '01';o_lab_cd:= '0042';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';o_lab_cd:= '0002';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';o_lab_cd:= '0001';--î≠íB
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';o_lab_cd:= '0011';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';o_lab_cd:= '0012';--‰På¥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';o_lab_cd:= '0021';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';o_lab_cd:= '0022';--îÁïÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';o_lab_cd:= '0031';--ë„é”
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';o_lab_cd:= '0041';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='08' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '08';o_div_cd:= '02';o_lab_cd:= '0051';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '01';o_lab_cd:= '0001';--ïaàˆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '01';o_lab_cd:= '0002';--êlëÃ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '01';o_lab_cd:= '0011';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '01';o_lab_cd:= '0012';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '01';o_lab_cd:= '0021';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '01';o_lab_cd:= '0022';--éÓ·á
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0001';--Functions
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0002';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0011';--èzä¬
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0012';--èzä¬
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0021';--êSîx
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0022';--êSîx
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0031';--êSîx
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0402') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0032';--Heart
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0041';--èzä¬
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0051';--ñÚï®
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0602') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0052';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0701') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0061';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0702') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '02';o_lab_cd:= '0062';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0001';--ëÃì‡
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0002';--êtëü
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0011';--ê∂êB
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0021';--îAòH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0022';--îÂîA
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0031';--é©ó•
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0402') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0032';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0041';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0051';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0701') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0061';--å`éø
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0801') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0071';--íÆäo
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0802') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0072';--ÉGÉs
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='09' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='0901') then o_fac_cd:= '22';o_dpt_cd:= '09';o_div_cd:= '03';o_lab_cd:= '0081';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0001';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0011';--éÓ·á
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0012';--ååât
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0021';--ëÃì‡
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0022';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0031';--ÉVÉO
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0041';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0502') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0042';--ënñÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0051';--Functions
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0602') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0052';--ënñÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0701') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0061';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0801') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0071';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='0901') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0081';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='1001') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0091';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='1101') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0101';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='1201') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '01';o_lab_cd:= '0111';--éæä≥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0101') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0001';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0102') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0002';--äÃí_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0201') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0011';--ëüäÌ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0202') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0012';--ãπïî
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0301') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0021';--ê“í≈
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0302') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0022';--êÆå`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0401') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0031';--âÊëú
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0501') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0041';--ïaóù
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0502') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0042';--êfíf
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0601') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0051';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0701') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0061';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='10' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='0801') then o_fac_cd:= '22';o_dpt_cd:= '10';o_div_cd:= '02';o_lab_cd:= '0071';--êlçH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0010') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0020') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0031') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--åíçN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0030') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0022';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0040') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0050') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--ñ@à„
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0060') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0022';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0070') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ê≠çÙ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0080') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0071';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0090') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0081';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0100') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0110') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0120') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0111';--ÉEÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0130') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0121';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0140') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0131';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0150') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0141';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0160') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0151';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0170') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0161';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0180') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0171';--ïÔäá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0190') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0181';--êlëÃ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0200') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0191';--êfíf
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0210') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0201';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0220') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0211';--ÉVÉO
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0230') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0221';--éæä≥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0240') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0231';--å`ê¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0250') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0241';--ì™ËÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0260') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0251';--éÓ·á
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0270') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0261';--â^ìÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0280') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0271';--å§ãÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0290') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0281';--ååó¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0300') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0291';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0310') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0302';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0320') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0311';--êSó√
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0330') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0321';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0340') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0331';--ã~ã}
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0350') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0341';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0360') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0351';--ä·â»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0370') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0361';--é®ï@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0380') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0371';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0390') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0381';--ê∏ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0400') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0391';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0410') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0401';--ååä«
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0420') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0411';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0430') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0421';--‰På¥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0440') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0431';--îÁïÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0450') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0441';--ìùçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0460') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0451';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0470') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0462';--Synthesis
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0480') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0471';--èzä¬
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0490') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0481';--êSîx
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0500') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0491';--Heart
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0510') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0501';--êtëü
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0520') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0511';--ê∂êB
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0530') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0521';--êtîÂ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0540') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0542';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0550') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0551';--åƒãz
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0560') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0561';--ååât
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0570') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0571';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0580') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0582';--äÃí_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0590') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0591';--êÆå`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0600') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0601';--ñÚï®
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0610') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0611';--ÉäÉn
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0620') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0621';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0630') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0631';--âÊëú
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0640') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0641';--êÊêi
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0650') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0651';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0660') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0661';--ç◊ã€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0670') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0671';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0680') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0681';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0690') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0691';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0700') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0701';--îFím
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0710') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0711';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0720') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0721';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0730') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0731';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0740') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0741';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0750') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0751';--åãçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0760') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0761';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0770') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0771';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0780') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0781';--ñ@éï
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0790') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0791';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0800') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0801';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0810') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0811';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0820') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0821';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0830') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0831';--ä{å˚
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0840') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0841';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0850') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0851';--ñÉêå
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0860') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0862';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0870') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0871';--è¨éô
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0880') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0881';--ô˘çá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0890') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0891';--Ç§êI
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0900') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0901';--ê€êH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0910') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0911';--éïêë
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0920') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0921';--ïîï™
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0930') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0931';--ÉCÉì
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0940') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0951';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0950') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0961';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0960') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0971';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0970') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0981';--éïé¸
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0980') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0991';--åíçN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0990') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1001';--ÉXÉ|
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1000') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1011';--çÇóÓ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1001') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1002') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1003') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0022';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1004') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1005') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--ñ@à„
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1006') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0022';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1007') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ê≠çÙ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1008') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0071';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1009') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0081';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1010') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1010') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1021';--è·äQ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1011') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1012') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0111';--ÉEÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1013') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0121';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1014') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0131';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1015') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0141';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1016') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0151';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1017') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0161';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1018') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0171';--ïÔäá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1019') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0181';--êlëÃ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1020') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1031';--Synthesis
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1020') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0191';--êfíf
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1021') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0201';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1022') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0211';--ÉVÉO
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1023') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0221';--éæä≥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1024') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0231';--å`ê¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1025') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0241';--ì™ËÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1026') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0251';--éÓ·á
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1027') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0261';--â^ìÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1028') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0271';--å§ãÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1029') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0281';--ååó¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1030') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1041';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1030') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0291';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1031') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0302';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1032') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0311';--êSó√
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1033') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0321';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1034') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0331';--ã~ã}
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1035') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0341';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1036') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0351';--ä·â»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1037') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0361';--é®ï@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1038') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0371';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1039') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0381';--ê∏ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1040') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1051';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1040') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0391';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1041') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0401';--ååä«
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1042') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0411';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1043') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0421';--‰På¥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1044') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0431';--îÁïÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1045') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0441';--ìùçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1046') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0451';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1047') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0462';--Synthesis
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1048') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0471';--èzä¬
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1049') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0481';--êSîx
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1050') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0491';--Heart
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1050') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0862';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1051') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0501';--êtëü
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1052') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0511';--ê∂êB
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1053') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0521';--êtîÂ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1054') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0542';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1055') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0551';--åƒãz
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1056') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0561';--ååât
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1057') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0571';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1058') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0582';--äÃí_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1059') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0591';--êÆå`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1060') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0531';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1060') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0601';--ñÚï®
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1061') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0611';--ÿ Àﬁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1062') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0621';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1063') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0631';--âÊëú
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1064') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0641';--êÊêi
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1066') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0661';--ç◊ã€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1067') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0671';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1068') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0681';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1069') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0691';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1070') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1081';--ã≥àÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1070') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0701';--îFím
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1071') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0711';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1072') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0721';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1073') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0731';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1074') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0741';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1075') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0751';--åãçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1076') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0761';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1077') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0771';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1079') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0791';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1080') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0801';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1080') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1091';--ê∂äU
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1081') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0811';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1082') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0821';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1083') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0831';--ä{å˚
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1084') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0841';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1085') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0851';--ñÉêå
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1086') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0862';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1087') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0871';--è¨éô
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1088') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0881';--ô˘çá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1089') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0891';--Ç§êI
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1090') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1101';--åíçN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1090') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0901';--ê€êH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1091') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0911';--éïêë
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1092') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0921';--ïîï™
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1093') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0931';--≤›Ãﬂ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1094') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0941';--ëSïî
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1095') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0951';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1096') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0961';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1097') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0971';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1098') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0981';--éïé¸
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1099') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0991';--åíçN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1100') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1001';--ÉXÉ|
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1100') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1111';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1101') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1011';--çÇóÓ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1102') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1021';--è·äQ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1104') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1041';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1105') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1051';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1106') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0862';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1107') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0531';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1108') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1081';--ã≥àÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1109') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1091';--ê∂äU
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1110') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1101';--åíçN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1110') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1121';--ínàÊ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1111') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1111';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1112') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1121';--ínàÊ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1113') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1131';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1114') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1141';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1115') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1151';--ã‡ëÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1116') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1161';--ñ≥ã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1117') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1171';--óLã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1118') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1181';--ÉZÉì
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1119') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1191';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1120') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1201';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1120') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1131';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1121') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1211';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1123') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1231';--ï®éø
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1124') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1241';--ñÚâª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1125') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1251';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1126') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1261';--à„ñÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1129') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1281';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1130') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1141';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1130') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1291';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1131') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1301';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1132') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1311';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1134') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1331';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1135') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1341';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1136') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1351';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1137') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1361';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1138') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1371';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1139') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1381';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1140') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1391';--ÉGÉs
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1140') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1151';--ã‡ëÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1141') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1401';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1142') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1411';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1143') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1421';FieldA
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1144') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1431';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1145') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1441';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1146') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1451';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1147') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1461';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1148') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1471';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1150') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1161';--ñ≥ã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1151') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1501';--óùå§
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1160') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1171';--óLã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1170') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1181';--ÉZÉì
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1180') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1191';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1190') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1201';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1200') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1211';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1210') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1222';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1220') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1231';--ï®éø
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1230') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1241';--ñÚâª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1240') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1251';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1250') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1261';--à„ñÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2030') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1262';--ÉÅÉf
       --deleted elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1260') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1270') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1271';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1280') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1281';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1290') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1291';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1300') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1301';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1310') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1311';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1320') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1321';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1330') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1331';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1340') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1341';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1350') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1351';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1360') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1361';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1370') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1371';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1380') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1381';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1390') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1391';--ÉGÉs
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1400') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1401';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1410') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1411';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1420') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1421';FieldA
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1430') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1431';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1440') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1441';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1450') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1451';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1460') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1461';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1470') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1471';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1480') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1482';--éæä≥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1490') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1491';--ë„é”
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1500') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1501';--óùå§
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1510') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1511';--NCNP
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1520') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1521';--ìsà„
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1530') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1531';--NCC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1540') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1551';--NCCH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1550') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1541';--éæä≥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2010') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2020') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='2001') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='01' and i_mrec.FieldArea='2002') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3001') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3002') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç◊ã€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3003') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3004') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3005') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3006') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0181';--óLã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3007') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0191';--Functions
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3008') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3009') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ä{å˚
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3010') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0071';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3011') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0081';--ñÉêå
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3012') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0092';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3013') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--è¨éô
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3014') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0111';--ô˘çá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3015') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0121';--Ç§êI
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3016') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0131';--ê€êH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3017') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0141';--éïêë
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3018') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0151';--ïîï™
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3019') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0161';--≤›Ãﬂ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='02' and i_mrec.FieldArea='3020') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0171';--ëSïî
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3021') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';--å`ê¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3022') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--ì™ËÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3023') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0021';--éÓ·á
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3024') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0031';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3025') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0041';--îFím
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3026') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0051';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3027') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0061';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3028') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0111';--ã‡ëÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3029') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0071';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3030') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0081';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3031') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0091';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='03' and i_mrec.FieldArea='3032') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0101';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3033') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0001';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3034') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0011';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3035') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0021';--â^ìÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3036') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0031';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3037') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0041';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3038') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0051';--åãçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3039') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0061';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3040') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0071';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3041') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0081';--ñ≥ã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='04' and i_mrec.FieldArea='3042') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0091';--éïé¸
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3043') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0002';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3044') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0011';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3045') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0021';--ñ@à„
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3046') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0002';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3047') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0041';--ê≠çÙ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3048') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0051';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3049') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0061';--å§ãÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3050') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0071';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3051') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0081';--êÊêi
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3053') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0101';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3054') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0111';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3055') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0121';--åíçN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3056') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0131';--ÉXÉ|
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3057') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0141';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='05' and i_mrec.FieldArea='3058') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0151';--ã≥àÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='06' and i_mrec.FieldArea='3059') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '21';o_lab_cd:= '0001';--ååó¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='06' and i_mrec.FieldArea='3060') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '21';o_lab_cd:= '0011';--ÿ Àﬁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='06' and i_mrec.FieldArea='3061') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '21';o_lab_cd:= '0021';--çÇóÓ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3062') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0001';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3063') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0012';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3064') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0021';--êSó√
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3065') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0031';--ñÚï®
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3066') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0041';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3067') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0051';--ã~ã}
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3068') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0061';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3069') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0071';--è·äQ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3071') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0091';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3072') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0101';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='07' and i_mrec.FieldArea='3073') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0092';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3074') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0001';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3075') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0011';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3076') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0021';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3077') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0031';FieldA
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3078') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0041';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3079') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0051';--ä·â»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3080') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0061';--é®ï@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3081') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0071';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3082') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0081';--ê∏ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3083') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0091';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='08' and i_mrec.FieldArea='3084') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0101';--ååä«
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3085') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0001';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3086') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0011';--ÉEÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3087') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0021';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3088') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0031';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3089') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0041';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3090') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0051';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3092') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0091';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3093') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0071';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3094') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0081';--‰På¥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='09' and i_mrec.FieldArea='3095') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0101';--îÁïÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3096') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0001';--êlëÃ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3097') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0011';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3098') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0021';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3100') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0041';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3101') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0051';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3102') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0171';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3104') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0181';--ìùçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3105') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0191';--éûä‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3106') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0061';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3107') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0071';--ìùçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3108') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0081';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3109') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0092';--Synthesis
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3110') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0101';--èzä¬
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3111') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0111';--êSîx
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3112') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0121';--Heart
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3113') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0131';--êtëü
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3114') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0141';--ê∂êB
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3115') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0151';--êtîÂ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3116') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0162';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='10' and i_mrec.FieldArea='3117') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0201';--åƒãz
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3010') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3020') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç◊ã€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3030') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3040') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3050') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3060') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0181';--óLã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3070') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0191';--Functions
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3080') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3090') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ä{å˚
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3100') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0071';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3110') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0081';--ñÉêå
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3118') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0001';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3119') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0011';--ºΩ√—
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3120') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0021';--ïÔäá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3120') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0092';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3121') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0031';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3122') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0041';--êfíf
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3123') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0051';--éæä≥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3124') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0061';--ÉVÉO
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3125') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0171';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3126') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0181';--à„ñÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3127') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0071';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3128') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0191';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3130') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--è¨éô
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3130') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0211';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3132') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0091';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3133') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0221';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3134') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0101';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3135') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0111';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3136') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0121';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3137') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0231';--ç\ë¢
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3138') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0131';--ååât
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3139') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0141';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3140') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0111';--ô˘çá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3143') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0152';--äÃí_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3141') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0161';--êÆå`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3142') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0241';--âÊëú
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3150') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0121';--Ç§êI
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3160') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0131';--ê€êH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3170') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0141';--éïêë
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3180') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0151';--ïîï™
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3190') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0161';--ÉCÉì
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='4460') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0201';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3200') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';--å`ê¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3210') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';--ì™ËÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3220') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0021';--éÓ·á
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3230') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0031';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3240') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0041';--îFím
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3250') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0051';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3260') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0061';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3270') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0111';--ã‡ëÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3280') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0071';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3290') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0081';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3300') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0091';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='3310') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0101';--ä{äÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3320') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0001';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3330') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0011';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3340') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0021';--â^ìÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3350') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0031';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3360') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0041';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3370') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0051';--åãçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3380') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0061';--çdëg
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3390') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0071';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3400') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0081';--ñ≥ã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='13' and i_mrec.FieldArea='3410') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0091';--éïé¸
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3420') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0002';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3430') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0011';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3440') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0021';--ñ@à„
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3450') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0002';--çëç€
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3460') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0041';--ê≠çÙ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3470') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0051';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3480') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0061';--å§ãÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3490') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0071';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3500') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0082';--êÊêi
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3510') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0091';--ñ@éï
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3520') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0101';--MedicalTreatment
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3530') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0111';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3540') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0121';--åíçN
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3550') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0131';--ÉXÉ|
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3560') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0141';--éïäw
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='14' and i_mrec.FieldArea='3570') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '16';o_lab_cd:= '0151';--ã≥àÁ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='15' and i_mrec.FieldArea='3580') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '21';o_lab_cd:= '0001';--ååó¨
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='15' and i_mrec.FieldArea='3590') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '21';o_lab_cd:= '0011';--ÉäÉn
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='15' and i_mrec.FieldArea='3600') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '21';o_lab_cd:= '0021';--çÇóÓ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3610') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0001';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3620') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0012';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3630') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0021';--êSó√
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3640') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0031';--ñÚï®
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3650') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0041';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3660') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0051';--ã~ã}
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3670') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0061';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3680') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0071';--è·äQ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3690') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0081';--Synthesis
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3700') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0091';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3710') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0101';--éïâ»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='16' and i_mrec.FieldArea='3720') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '26';o_lab_cd:= '0092';--OralCavity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3730') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0001';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3740') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0011';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3750') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0021';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3760') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0031';FieldA
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3770') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0041';--Nerve
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3780') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0051';--ä·â»
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3790') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0061';--é®ï@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3800') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0071';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3810') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0081';--ê∏ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3820') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0091';--î]ê_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='3830') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0101';--ååä«
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='17' and i_mrec.FieldArea='4430') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '31';o_lab_cd:= '0111';--NCNP
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3840') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0001';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3850') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0011';--ÉEÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3860') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0021';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3870') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0031';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3880') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0041';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3890') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0051';--ïaë‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3900') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0061';--ë„é”
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3910') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0091';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3920') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0071';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3930') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0081';--‰På¥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='3940') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0101';--îÁïÜ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='18' and i_mrec.FieldArea='4450') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '36';o_lab_cd:= '0111';--NCCH
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='3950') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0001';--êlëÃ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='3960') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0011';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='3970') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0021';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='3980') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0031';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='3990') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0041';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4000') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0051';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4010') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0171';--Cell
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4020') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0181';--ìùçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4030') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0191';--éûä‘
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4040') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0061';--ä≤ç◊
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4050') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0071';--ìùçá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4060') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0081';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4070') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0092';--Synthesis
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4080') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0101';--èzä¬
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4090') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0111';--êSîx
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4100') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0121';--Heart
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4110') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0131';--êtëü
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4120') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0141';--ê∂êB
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4130') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0151';--êtîÂ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4140') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0162';--è¡âª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4150') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0201';--åƒãz
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='19' and i_mrec.FieldArea='4440') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '41';o_lab_cd:= '0211';--ìsà„
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4160') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0001';--ó’è∞
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4170') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0011';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4180') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0021';--ïÔäá
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4190') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0031';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4200') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0041';--êfíf
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4210') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0051';--éæä≥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4220') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0061';--ÉVÉO
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4230') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0171';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4240') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0181';--à„ñÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4250') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0071';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4260') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0191';--êÊí[
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4270') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0201';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4280') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0211';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4290') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0082';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4300') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0091';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4310') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0221';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4320') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0101';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4330') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0111';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4340') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0121';--à‚ì`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4350') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0231';--ç\ë¢
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4360') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0131';--ååât
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4370') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0141';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4380') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0152';--äÃí_
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4390') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0161';--êÆå`
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4400') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0241';--âÊëú
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4410') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0251';--éæä≥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='20' and i_mrec.FieldArea='4420') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0261';--éæä≥
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4001') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4002') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ÉZÉì
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4003') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4004') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4005') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--ï®éø
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4006') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';--ñÚâª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4007') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4008') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0241';--ënñÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4009') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0191';--ã‡ëÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4010') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0201';--ñ≥ã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4011') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0211';--óLã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4013') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0081';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4014') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4015') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4016') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0111';--ÉGÉs
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4017') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0121';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4018') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0131';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4019') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0141';--çÇéü
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4020') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0151';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4021') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0221';--é°ó√
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4022') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0161';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4023') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0171';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4024') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0231';--ÉQÉm
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4025') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0181';--óùå§
       --deleted elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4026') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--Ç®íÉ
       --deleted elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='12' and i_mrec.FieldArea='4027') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ñkó¢
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5010') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5020') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ÉZÉì
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5030') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5040') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--ÉoÉC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5050') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--ï®éø
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5060') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';--ñÚâª
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5070') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5080') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0241';--ënñÚ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5090') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0191';--ã‡ëÆ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5100') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0201';--ñ≥ã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5110') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0211';--óLã@
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5120') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0071';--ê∂ñΩ
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5130') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0081';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5140') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--î≠ê∂
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5150') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--Immunity
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5160') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0111';--ÉGÉs
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5170') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0121';-- Sys
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5180') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0131';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5190') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0141';--çÇéü
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5200') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0151';--LivingBody
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5210') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0221';--é°ó√
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5220') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0161';--ï™éq
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5230') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0171';--ä¬ã´
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5240') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0231';--ÉQÉm
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5250') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0181';--óùå§
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5260') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0251';--NCC
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='13' and i_mrec.MiddleCourse='21' and i_mrec.FieldArea='5270') then o_fac_cd:= '36';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0242';--ÉÅÉf
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--å`éø
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--å`éø
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0102') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--Cell
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0102') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--Cell
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0201') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';-- Sys
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0201') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';-- Sys
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0301') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ç\ë¢
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0301') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ç\ë¢
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0303' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0303' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0303' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0303' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®äw(à…ì°)=>ç\ë¢ê∂ï®äwFieldArea
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ï™éq
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ï™éq
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0403' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0501') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ï™éqCell
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0501') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ï™éqCell
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0502') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--CellFunctions
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0502') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--CellFunctions
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0601') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--genomeëΩ
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0601') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--genomeëΩ
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0602' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉmArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0602' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genomeea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0602' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉmArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0602' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genomeea
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0701') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--åvéZÉvÉçÉeÉIÉ~ÉNÉX=>åvéZÉvÉçÉeÉIÉ~ÉNÉX
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0701') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--åvéZÉvÉçÉeÉIÉ~ÉNÉX=>åvéZÉvÉçÉeÉIÉ~ÉNÉX
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0702' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´ÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0702' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´œ√ÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0702' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´ÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0702' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´œ√ÉXFieldArea
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0801') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--Cell informatics=>Cell informatics
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0801') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--Cell informatics=>Cell informatics
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0802' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´ÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0802' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´œ√ÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0802' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´ÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0802' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´œ√ÉXFieldArea
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0901') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--LivingBodyï™éqÉÇÉfÉäÉìÉO=>LivingBodyï™éqÉÇÉfÉäÉìÉO
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0901') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--LivingBodyï™éqÉÇÉfÉäÉìÉO=>LivingBodyï™éqÉÇÉfÉäÉìÉO
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0902' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´ÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0902' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´œ√ÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0902' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´ÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0902' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´œ√ÉXFieldArea
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1001') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ê∂ñΩèÓïÒä«óùäw=>ê∂ñΩèÓïÒä«óùäw
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1001') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ê∂ñΩèÓïÒä«óùäw=>ê∂ñΩèÓïÒä«óùäw
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1101') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--genomeèÓïÒâ»äw=>genomeèÓïÒâ»äw
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1101') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--genomeèÓïÒâ»äw=>genomeèÓïÒâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1102' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´ÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1102' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';-- ﬁ≤µ≤›Ã´œ√ÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉmArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genomeea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1401') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--î≠ê∂ÅEê∂êB=>î≠ê∂ÅEê∂êB
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1401') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--î≠ê∂ÅEê∂êB=>î≠ê∂ÅEê∂êB
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1501') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--CellFunctionsêßå‰äw(çïñˆ)=>CellFunctionsêßå‰äw(çïñˆ)
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1501') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--CellFunctionsêßå‰äw(çïñˆ)=>CellFunctionsêßå‰äw(çïñˆ)
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉmArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genomeea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉmArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genomeea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1801' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1801' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1801' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1801' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉCÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉCÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉCÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉCÉIÉçÉWÅ[FieldArea
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2101') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--CellFunctionsêßå‰äw(ç°ñ{)=>CellFunctionsêßå‰äw(ç°ñ{)
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2101') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--CellFunctionsêßå‰äw(ç°ñ{)=>CellFunctionsêßå‰äw(ç°ñ{)
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2201') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--CellFunctionsêßå‰äw(çrêÏ)=>CellFunctionsêßå‰äw(çrêÏ)
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2201') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--CellFunctionsêßå‰äw(çrêÏ)=>CellFunctionsêßå‰äw(çrêÏ)
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System Area
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System Area
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2301' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉCÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉìÉtÉHÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw(óÈ
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw(óÈ
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2801') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--î≠ê∂ÅEê∂êBâ»äw(êÛå¥)=>î≠ê∂ÅEê∂êBâ»äw(êÛå¥)
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2801') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--î≠ê∂ÅEê∂êBâ»äw(êÛå¥)=>î≠ê∂ÅEê∂êBâ»äw(êÛå¥)
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2901') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--î≠ê∂ÅEê∂êBâ»äw(èèï˚)=>î≠ê∂ÅEê∂êBâ»äw(èèï˚)
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2901') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--î≠ê∂ÅEê∂êBâ»äw(èèï˚)=>î≠ê∂ÅEê∂êBâ»äw(èèï˚)
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3002' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠åª
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠åª
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠åª
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠åª
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System 
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System 
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System 
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System 
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3006' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3006' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3006' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉ}ÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3006' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0061';--ÉoÉCÉIÉCÉìÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw=>ñ∆
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw=>ñ∆
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw=>ñ∆
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3007' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--Immunityäw=>ñ∆
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3008' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--î≠ê∂ÅEê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3008' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--î≠ê∂ÅEê∂êB
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3008' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--î≠ê∂ÅEê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='01' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3008' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--î≠ê∂ÅEê∂êB
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw=>ñ∆
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw=>ñ∆
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw=>ñ∆
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw=>ñ∆
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0102' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0102' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(í’
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0102' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0102' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(í’
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0201') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';
       --deleted  elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0201') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0202' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0202' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0202' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0202' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0301') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ÉÅÉfÉBÉVÉiÉãÉPÉ~ÉXÉgÉäÅ[=>ÉÅÉfÉBÉVÉiÉãÉPÉ~ÉXÉgÉäÅ[
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0301') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ÉÅÉfÉBÉVÉiÉãÉPÉ~ÉXÉgÉäÅ[=>ÉÅÉfÉBÉVÉiÉãÉPÉ~ÉXÉgÉäÅ[
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--π–∂Ÿ ﬁ≤µieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--π–∂Ÿ ﬁ≤µ€ºldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--π–∂Ÿ ﬁ≤µieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0302' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--π–∂Ÿ ﬁ≤µ€ºldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0401' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--π–∂Ÿ ﬁ≤µieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--π–∂Ÿ ﬁ≤µ€ºldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--π–∂Ÿ ﬁ≤µieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0402' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--π–∂Ÿ ﬁ≤µ€ºldArea
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0501') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ê∂ñΩ System ÉÇÉfÉäÉìÉO=>ê∂ñΩ System ÉÇÉfÉäÉìÉO
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0501') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ê∂ñΩ System ÉÇÉfÉäÉìÉO=>ê∂ñΩ System ÉÇÉfÉäÉìÉO
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0502') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ê∂ñΩºΩ√—”√ﬁÿ›∏ﬁ(ëùìc)=>ê∂ñΩºΩ√—”√ﬁÿ›∏ﬁ(ëùìc)
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0502') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--ê∂ñΩºΩ√—”√ﬁÿ›∏ﬁ(ëùìc)=>ê∂ñΩºΩ√—”√ﬁÿ›∏ﬁ(ëùìc)
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0101';--Pharmacologyäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0101';--Pharmacologyäw=>ñÚ
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0101';--Pharmacologyäw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0101';--Pharmacologyäw=>ñÚ
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0701') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--genomeç\ë¢êßå‰=>genomeç\ë¢êßå‰
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0701') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--genomeç\ë¢êßå‰=>genomeç\ë¢êßå‰
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0702' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉmArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0702' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genomeea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0702' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉmArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0702' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genomeea
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0801') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--LivingBodyForeign matterèÓïÒäw=>LivingBodyForeign matterèÓïÒäw
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0801') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';--LivingBodyForeign matterèÓïÒäw=>LivingBodyForeign matterèÓïÒäw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0802' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0802' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(óù
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0802' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0802' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(óù
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='0901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1001') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1001') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉIÉçÉWÅ[FieldArea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1201' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';--ÉPÉ~ÉJÉãÉoÉçÉWÅ[FieldArea
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1301') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1301') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1401') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';
       --deleted elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1401') then o_fac_cd:= '';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(êƒ
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1501' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(êƒ
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(çï
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1601' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(çï
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(ã{
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1701' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';--Immunityäw(ã{
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1801' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1801' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(H
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1801' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1801' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(H
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1901' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='2101' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw(
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥ÉQÉm
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3001' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0001';--éæä≥genome
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠åª
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠åª
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠åª
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠ea
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3003' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0031';--à‚ì`éqî≠åª
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3004' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0041';--Cellê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';-- System 
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';-- System 
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';-- System 
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';-- System 
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3005' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';-- System ê∂
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3009' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0011';--ç\ë¢ê∂ï®äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw=>
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Previous term]') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw
       elsif(i_mrec.GraduateCourse='06' and i_mrec.Major='02' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='3010' and mig_lib.get_process(i_mrec.XXXXX,i_mrec.XXXXX)='Doctor[Latter term]') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';--Nerveâ»äw=>

       /* èdï°CDèCê≥ */
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1161') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--CellPharmacologyäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1010') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1021';--Handicappedéïâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1020') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1031';--Synthesisêfó√éïâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1162') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0191';--êfífïaóùäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1030') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1041';--éïâ»êSêgà„äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1163') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0291';--ó’è∞Inspectionà„äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1040') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1051';--éïâ»MedicalTreatmentçsìÆâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1164') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0391';--î]NerveFunctionsäOâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1165') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0491';--Heartååä«äOâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1050') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0862';--OralCavityFacialPainêßå‰äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1060') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0531';--éïäwã≥àÁ System ï]âøäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1166') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0601';--ñÚï®ìÆë‘äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1070') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1081';--ã≥àÁÉÅÉfÉBÉAäJî≠äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1167') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0701';--îFímNerveê∂ï®äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1168') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0801';--éïäwã≥àÁäJî≠äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1080') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1091';--ê∂äUOralCavityXXXFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1090') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1101';--åíçNéxâáOralCavityXXXFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1169') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0901';--ê€êHFunctionsï€ë∂äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1171') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1001';--ÉXÉ|Å|Écà„éïäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1100') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1111';--OralCavityéæä≥ó\ñhäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1172') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1101';--åíçNéxâáOralCavityXXXFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1110') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1121';--ínàÊÅEïüéÉOralCavityXXXFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1173') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1201';--ÉoÉCÉIÉGÉåÉNÉgÉçÉjÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1120') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1131';--OralCavityåíçNã≥àÁäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1130') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1141';--OralCavityï€åíâqê∂äÓëbäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1174') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1291';--NerveïaóùäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1175') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1391';--ÉGÉsÉWÉFÉlÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='11' and i_mrec.MiddleCourse='0' and i_mrec.FieldArea='1140') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1151';--ã‡ëÆçﬁóøäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3151') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0021';--ïÔäáïaóùäwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3120') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0092';--OralCavityFacialPainêßå‰äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3130') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--è¨éôéïâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='4' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3152') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0211';--LivingBodyäEñ çHäwFieldArea
       /* èdï°CDèCê≥(ÇQåÖÇæÇ¡ÇΩéûópÇÃ) */
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1161') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0091';--CellPharmacologyäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1010') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1021';--Handicappedéïâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1020') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1031';--Synthesisêfó√éïâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1162') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0191';--êfífïaóùäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1030') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1041';--éïâ»êSêgà„äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1163') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0291';--ó’è∞Inspectionà„äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1040') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1051';--éïâ»MedicalTreatmentçsìÆâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1164') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0391';--î]NerveFunctionsäOâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1165') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0491';--Heartååä«äOâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1050') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0862';--OralCavityFacialPainêßå‰äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1060') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0531';--éïäwã≥àÁ System ï]âøäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1166') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0601';--ñÚï®ìÆë‘äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1070') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1081';--ã≥àÁÉÅÉfÉBÉAäJî≠äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1167') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0701';--îFímNerveê∂ï®äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1168') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0801';--éïäwã≥àÁäJî≠äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1080') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1091';--ê∂äUOralCavityXXXFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1090') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1101';--åíçNéxâáOralCavityXXXFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1169') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0901';--ê€êHFunctionsï€ë∂äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1171') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1001';--ÉXÉ|Å|Écà„éïäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1100') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1111';--OralCavityéæä≥ó\ñhäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1172') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1101';--åíçNéxâáOralCavityXXXFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1110') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1121';--ínàÊÅEïüéÉOralCavityXXXFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1173') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1201';--ÉoÉCÉIÉGÉåÉNÉgÉçÉjÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1120') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1131';--OralCavityåíçNã≥àÁäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1130') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1141';--OralCavityï€åíâqê∂äÓëbäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1174') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1291';--NerveïaóùäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1175') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1391';--ÉGÉsÉWÉFÉlÉeÉBÉNÉXFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='11' and i_mrec.MiddleCourse='00' and i_mrec.FieldArea='1140') then o_fac_cd:= '31';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '1151';--ã‡ëÆçﬁóøäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3151') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0021';--ïÔäáïaóùäwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3120') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0092';--OralCavityFacialPainêßå‰äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3130') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';--è¨éôéïâ»äwFieldArea
       elsif(i_mrec.GraduateCourse='04' and i_mrec.Major='12' and i_mrec.MiddleCourse='11' and i_mrec.FieldArea='3152') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0211';--LivingBodyäEñ çHäwFieldArea

         /* End of aotomatically generate source */
       else
         if(i_mrec.FieldArea is not null) then
             MIG_LOGGER.write_log('E03-4',i_mrec.XXXXX,'[Doc  No.03-4]GraduateCourse,Major,MiddleCourse,FieldArea[doesn't match] '||i_mrec.GraduateCourse||' '||i_mrec.Major||' '||i_mrec.MiddleCourse||' '||i_mrec.FieldArea||' i_mrec.XXX='||i_mrec.XXX||' mig_lib.get_period_from_stu_cd_header(a_stu_cd_header)='||mig_lib.get_period_from_stu_cd_header(i_mrec.XXX));
             o_txt:='[DestinationFieldArea(Field/Area)Unknown]'||'[OldGraduateCourse=]'||i_mrec.GraduateCourse||'[OldMajor=]'||i_mrec.Major||'[OldMiddleCourse=]'||i_mrec.MiddleCourse||'[OldFieldArea=]'||i_mrec.FieldArea;
             o_lab_cd:= '9999';
         end if;
       end if;

       if(o_fac_cd=null and o_dpt_cd=null and o_div_cd=null and o_lab_cd=null) then
        MIG_LOGGER.write_log('E99-1',i_mrec.XXXXX,'GraduateCourse,Major,MiddleCourse,FieldAreaÇ©ÇÁäwïî,Department,Course,Field/AreaÇ…à⁄çsÇ≈Ç´Ç‹ÇπÇÒ '||i_mrec.GraduateCourse||' '||i_mrec.Major||' '||i_mrec.MiddleCourse||' '||i_mrec.FieldArea||' i_mrec.XXX='||i_mrec.XXX||' mig_lib.get_period_from_stu_cd_header(a_stu_cd_header)='||mig_lib.get_period_from_stu_cd_header(i_mrec.XXX));
        o_fac_cd:= '98';
       end if;
    end;
   
    function get_regular_cd(
        i_stu_div_cd       in     varchar2                --> XXXXX
    )return varchar2                                      --< Regular
    is
        o_regular_cd varchar2(1);
    begin
        case i_stu_div_cd
            when '11' then o_regular_cd  := '1'; --Regular
            when '12' then o_regular_cd  := '1'; --Regular
            when '13' then o_regular_cd  := '1'; --Regular
            when '14' then o_regular_cd  := '1'; --Regular
            when '15' then o_regular_cd  := '1'; --Regular
            when '16' then o_regular_cd  := '1'; --Regular
            when '21' then o_regular_cd  := '9'; --Non-Regular
            when '31' then o_regular_cd  := '9'; --Non-Regular
            when '32' then o_regular_cd  := '9'; --Non-Regular
            when '33' then o_regular_cd  := '9'; --Non-Regular
            when '39' then o_regular_cd  := '9'; --Non-Regular
            when '41' then o_regular_cd  := '9'; --Non-Regular
            when '42' then o_regular_cd  := '9'; --Non-Regular
            when '43' then o_regular_cd  := '9'; --Non-Regular
            when '44' then o_regular_cd  := '9'; --Non-Regular
            when '45' then o_regular_cd  := '9'; --Non-Regular
            when '49' then o_regular_cd  := '9'; --Non-Regular
            when '61' then o_regular_cd  := '9'; --Non-Regular
            when '62' then o_regular_cd  := '9'; --Non-Regular
            when '63' then o_regular_cd  := '9'; --Non-Regular
            when '69' then o_regular_cd  := '9'; --Non-Regular
            when '71' then o_regular_cd  := '9'; --Non-Regular
            when '72' then o_regular_cd  := '9'; --Non-Regular
            when '73' then o_regular_cd  := '9'; --Non-Regular
            when '74' then o_regular_cd  := '9'; --Non-Regular
            when '75' then o_regular_cd  := '9'; --Non-Regular
            when '79' then o_regular_cd  := '9'; --Non-Regular
            when '7Z' then o_regular_cd  := '9'; --Non-Regular
            when '81' then o_regular_cd  := '9'; --Non-Regular
            when '82' then o_regular_cd  := '9'; --Non-Regular
            when '83' then o_regular_cd  := '9'; --Non-Regular
            when '89' then o_regular_cd  := '9'; --Non-Regular
            when '98' then o_regular_cd  := 'X'; --Unknown
            when '99' then o_regular_cd  := '9'; --Non-Regular
            else           o_regular_cd  := 'Z'; --Unknown
        end case;
        return o_regular_cd;
    end;   
    
    function get_elder_cd(
        i_mrec             in     mdb.m_doctor%rowtype    --> MDB.M_DOCTOR type record(s)
    )return varchar2                                      --<  some type 
    is
        o_elder_cd varchar2(2);
    begin
        if(i_mrec.é–âÔêlì¸äw=2) then o_elder_cd := '99';
        else                         o_elder_cd := '00';
        end if;
        return o_elder_cd;
    end;

    function get_abroad_cd(
        i_mrec             in     mdb.m_doctor%rowtype    --> MDB.M_DOCTOR type record(s)
    )return varchar2                                      --< óØXXXXX
    is
        o_abroad_cd varchar2(2);
    begin
        if   (i_mrec.óØäwê∂=0) then o_abroad_cd:='00';
        elsif(i_mrec.óØäwê∂=1) then o_abroad_cd:='98';
        elsif(i_mrec.óØäwê∂=2) then o_abroad_cd:='99';
        else                        o_abroad_cd:=i_mrec.óØäwê∂;
        end if;
        return o_abroad_cd;
    end;

    procedure get_na_cd(
        i_mrec             in     mdb.m_doctor%rowtype,    --> MDB.M_DOCTOR type record(s)
        o_origin_cd        out    varchar2,                --< ñ{ê– code(s)
        o_na_cd            out    varchar2                 --> çëê– code(s)
    )
    is
         a_home_ground_str        varchar2(100);
         a_home_ground_jp_cd      varchar2(8);
         a_home_ground_ab_cd      varchar2(8);
    begin
        a_home_ground_str:=trim('Å@' from trim(i_mrec.ñ{ê–));
        a_home_ground_jp_cd:=mig_lib.get_cd_from_origin(a_home_ground_str);
        if   (a_home_ground_jp_cd is not null) then                                                       -- ì˙ñ{(47ìsìπï{åß)ÇÃèÍçá
            o_origin_cd:=a_home_ground_jp_cd;
            o_na_cd    :='123';--ì˙ñ{
        else                                                                                              -- äOçëê–ÇÃèÍçá
            a_home_ground_ab_cd:=mig_lib.get_cd_from_nation(a_home_ground_str);
            if(a_home_ground_ab_cd is not null) then                                                        -- NATION TABLEÇ©ÇÁCDÇéÊìæÇ≈Ç´ÇΩèÍçá
                o_na_cd    :=a_home_ground_ab_cd;
            else                                                                                            -- NATION TABLEÇ©ÇÁCDÇéÊìæÇ≈Ç»Ç©Ç¡ÇΩèÍçá
                /* ÉeÉLÉXÉgÅÅÅÑ code(s)ïœä∑Ç≈èàóùÇµÇ´ÇÍÇ»Ç¢ñ{ê–à⁄çsÇSTART */
                case a_home_ground_str
                    --when 'ìﬁó«åßÅ@' then a_rec.origin_cd:='29';
                    when 'LAO'                  then o_na_cd    :='119';
                    when 'ÉCÉâÉì'               then o_na_cd    :='201';
                    when 'Singapore'            then o_na_cd    :='109';
                    when 'ÉAÉ[ÉãÉoÉCÉWÉÉÉì'     then o_na_cd    :='753';
                    when 'ÉAÉtÉKÉjÉXÉ^Éì'       then o_na_cd    :='211';
                    when 'ÉIÅ[ÉXÉgÉâÉäÉA'       then o_na_cd    :='718';
                    when 'ÉAÉÅÉäÉJ'             then o_na_cd    :='502';
                    when 'ÉCÉGÉÅÉì'             then o_na_cd    :='213';
                    when 'ÉCÉâÉN'               then o_na_cd    :='208';
                    when 'ÉCÉìÉhÉlÉVÉA'         then o_na_cd    :='110';
                    when 'ÉGÉWÉvÉg'             then o_na_cd    :='301';
                    when 'ÉJÉgÉ}ÉìÉY'           then o_na_cd    :='103';
                    when 'ÉJÉìÉ{ÉWÉA'           then o_na_cd    :='117';
                    when 'ÉKÅ[Éi'               then o_na_cd    :='311';
                    when 'ÉLÉvÉçÉX'             then o_na_cd    :='773';
                    when 'ÉLÉãÉMÉXÉ^Éì'         then o_na_cd    :='752';
                    when 'ÉMÉjÉA'               then o_na_cd    :='321';
                    when 'ÉRÉçÉìÉrÉA'           then o_na_cd    :='616';
                    when 'ÉRÅ[ÉgÉWÉ{ÉèÅ[Éã'     then o_na_cd    :='317';
                    when 'ÉTÉEÉWÉAÉâÉrÉA'       then o_na_cd    :='210';
                    when 'ÉVÉäÉA'               then o_na_cd    :='204';
                    when 'ÉVÉäÉAÉAÉâÉuã§òaçë'   then o_na_cd    :='204';
                    when 'ÉVÉìÉKÉ|Å[Éã'         then o_na_cd    :='109';
                    when 'ÉXÉEÉFÅ[ÉfÉì'         then o_na_cd    :='703';
                    when 'ÉXÉäÉâÉìÉJ'           then o_na_cd    :='105';
                    when 'ÉXÅ[É_Éì'             then o_na_cd    :='302';
                    when 'É^ÉC'                 then o_na_cd    :='107';
                    when 'É^ÉìÉUÉjÉA'           then o_na_cd    :='308';
                    when 'ÉgÉãÉR'               then o_na_cd    :='202';
                    when 'ÉhÉCÉc'               then o_na_cd    :='711';
                    when 'ÉiÉCÉWÉFÉäÉA'         then o_na_cd    :='310';
                    when 'ÉjÉJÉâÉOÉA'           then o_na_cd    :='604';
                    when 'ÉlÉpÅ[Éã'             then o_na_cd    :='103';
                    when 'ÉnÉCÉ`'               then o_na_cd    :='633';
                    when 'ÉoÉìÉOÉâÉfÉBÉVÉÖ'     then o_na_cd    :='104';
                    when 'ÉoÉìÉOÉâÉfÉVÉÖ'       then o_na_cd    :='104';
                    when 'ÉoÉìÉOÉâÉfÉbÉVÉÖ'     then o_na_cd    :='104';
                    when 'ÉoÅ[ÉåÅ[Éì'           then o_na_cd    :='215';
                    when 'ÉpÉLÉXÉ^Éì'           then o_na_cd    :='101';
                    when 'ÉpÉâÉOÉAÉC'           then o_na_cd    :='609';
                    when 'ÉtÉBÉWÅ['             then o_na_cd    :='404';
                    when 'ÉtÉBÉäÉsÉì'           then o_na_cd    :='111';
                    when 'ÉtÉâÉìÉX'             then o_na_cd    :='712';
                    when 'ÉuÉâÉWÉã'             then o_na_cd    :='608';
                    when 'ÉuÉãÉKÉäÉA'           then o_na_cd    :='726';
                    when 'ÉxÉgÉiÉÄ'             then o_na_cd    :='115';
                    when 'ÉxÉlÉYÉGÉâ'           then o_na_cd    :='617';
                    when 'ÉxÉâÉãÅ[ÉV'           then o_na_cd    :='736';
                    when 'ÉyÉãÅ['               then o_na_cd    :='614';
                    when 'ÉzÉìÉWÉÖÉâÉX'         then o_na_cd    :='618';
                    when 'É{ÉXÉjÉA'             then o_na_cd    :='740';
                    when 'É|Å[ÉâÉìÉh'           then o_na_cd    :='721';
                    when 'É~ÉÉÉìÉ}Å['           then o_na_cd    :='106';
                    when 'ÉÅÉLÉVÉR'             then o_na_cd    :='601';
                    when 'ÉÇÉìÉSÉã'             then o_na_cd    :='114';
                    when 'ÉàÉãÉ_Éì'             then o_na_cd    :='207';
                    when 'ÉâÉIÉX'               then o_na_cd    :='119';
                    when 'ÉäÉgÉAÉjÉA'           then o_na_cd    :='731';
                    when 'ÉäÉrÉA'               then o_na_cd    :='390';
                    when 'ÉåÉoÉmÉì'             then o_na_cd    :='205';
                    when 'ÉîÉFÉlÉYÉGÉâ'         then o_na_cd    :='617';
                    when 'íÜçë'                 then o_na_cd    :='116';
                    when 'íÜçë(‡cózés)'         then o_na_cd    :='116';
                    when 'íÜçëçLìåè»'           then o_na_cd    :='116';
                    when 'íÜçëêV·d'             then o_na_cd    :='116';
                    when 'íÜçëó…îJè»ëÂòAés'     then o_na_cd    :='116';
                    when 'í©ëN'                 then o_na_cd    :='902';
                    when 'ñ≥ãLì¸'               then o_na_cd    :='801';
                    when 'ïƒçë Õﬂ›ºŸ ﬁ∆±èB'     then o_na_cd    :='502';
                    when 'âpçë'                 then o_na_cd    :='707';
                    when 'äÿçë'                 then o_na_cd    :='113';
                    when '±Ã∂ﬁ∆Ω¿›'             then o_na_cd    :='211';
                    when '≤¥“›'                 then o_na_cd    :='213';
                    when '≤◊›'                  then o_na_cd    :='201';
                    when '≤›ƒﬁ'                 then o_na_cd    :='102';
                    when '≤›ƒﬁ»º±'              then o_na_cd    :='110';
                    when '≥∏◊≤≈'                then o_na_cd    :='733';
                    when '∂›Œﬁºﬁ±'              then o_na_cd    :='117';
                    when '∑Ÿ∑ﬁΩ'                then o_na_cd    :='752';
                    when 'ª≥ºﬁ±◊Àﬁ±'            then o_na_cd    :='210';
                    when 'ΩÕﬂ≤›'                then o_na_cd    :='713';
                    when 'Ωÿ◊›∂'                then o_na_cd    :='105';
                    when 'æŸÀﬁ±'                then o_na_cd    :='724';
                    when '¿≤'                   then o_na_cd    :='107';
                    when '¿≤‹›'                 then o_na_cd    :='122';
                    when 'ƒŸ∫'                  then o_na_cd    :='202';
                    when '» ﬂ∞Ÿ'                then o_na_cd    :='103';
                    when ' ﬁ›∏ﬁ◊√ﬁ®Øº≠'         then o_na_cd    :='104';
                    when ' ﬁ›∏ﬁ◊√ﬁ®º≠'          then o_na_cd    :='104';
                    when ' ﬁ›∏ﬁ◊√ﬁº≠'           then o_na_cd    :='104';
                    when 'Ã®ÿÀﬂ›'               then o_na_cd    :='111';
                    when 'Õﬁƒ≈—'                then o_na_cd    :='115';
                    when 'ÕﬂŸ∞'                 then o_na_cd    :='614';
                    when '–¨›œ∞'                then o_na_cd    :='106';
                    when '“∑º∫'                 then o_na_cd    :='601';
                    when '”›∫ﬁŸ'                then o_na_cd    :='114';
                    when 'ÿÀﬁ±'                 then o_na_cd    :='390';
                    else MIG_LOGGER.write_log('EORAB01',i_mrec.XXXXX,'ñ{ê–Ç™à⁄çsÇ≈Ç´Ç‹ÇπÇÒÅB i_mrec.ñ{ê–='||i_mrec.ñ{ê–);
                end case;
            end if;
        end if;
    end;

    function get_sr_relation_cd(
        i_mrec             in     mdb.m_doctor%rowtype    --> MDB.M_DOCTOR type record(s)
    )return varchar2                                      --< ï€èÿêlë±ïø
    is
        o_sr_relation_cd varchar2(2);
    begin
        case trim(i_mrec.ï€èÿêl_ë±ïø)
          when 'SomeValue'  then o_sr_relation_cd    :='01';
          when 'SomeValue'  then o_sr_relation_cd    :='02';
          when 'SomeValue'  then o_sr_relation_cd    :='06';
          when 'SomeValue'  then o_sr_relation_cd    :='06';
          when 'SomeValue'  then o_sr_relation_cd    :='99';
          when 'SomeValue'  then o_sr_relation_cd    :='99';
          when 'SomeValue'  then o_sr_relation_cd    :='99';
          when 'SomeValue'  then o_sr_relation_cd    :=NULL;
          when 'SomeValue'  then o_sr_relation_cd    :=NULL;
          when 'SomeValue'  then o_sr_relation_cd    :=NULL;
          when 'SomeValue'  then o_sr_relation_cd    :=NULL;
          when 'SomeValue'  then o_sr_relation_cd    :=NULL;
          when 'SomeValue'  then o_sr_relation_cd    :='19';
          when 'SomeValue'  then o_sr_relation_cd    :='19';
          when 'SomeValue'  then o_sr_relation_cd    :='05';
          when 'SomeValue'  then o_sr_relation_cd    :='05';
          when 'SomeValue'  then o_sr_relation_cd    :='05';
          when 'SomeValue'  then o_sr_relation_cd    :='99';
          when 'SomeValue'  then o_sr_relation_cd    :='05';
          when 'SomeValue'  then o_sr_relation_cd    :='06';
          when 'SomeValue'  then o_sr_relation_cd    :='02';
          when 'SomeValue'  then o_sr_relation_cd    :='01';
          when 'SomeValue'  then o_sr_relation_cd    :='05';
          when 'SomeValue'  then o_sr_relation_cd    :='05';
          when 'SomeValue'  then o_sr_relation_cd    :='08';
          when 'SomeValue'  then o_sr_relation_cd    :='10';
          when 'SomeValue'  then o_sr_relation_cd    :='11';
          when 'SomeValue'  then o_sr_relation_cd    :='05';
          when 'SomeValue'  then o_sr_relation_cd    :='05';
          when 'SomeValue'  then o_sr_relation_cd    :='09';
          when 'SomeValue'  then o_sr_relation_cd    :='19';
          when 'SomeValue'  then o_sr_relation_cd    :='10';
          when 'SomeValue'  then o_sr_relation_cd    :='08';
          when 'SomeValue'  then o_sr_relation_cd    :='05';
          when 'SomeValue'  then o_sr_relation_cd    :='06';
          when 'SomeValue'  then o_sr_relation_cd    :='06';
          when 'SomeValue'  then o_sr_relation_cd    :='99';
          when 'SomeValue'  then o_sr_relation_cd    :='99';
          when 'SomeValue'  then o_sr_relation_cd    :='99';
          when 'SomeValue'  then o_sr_relation_cd    :='99';
          else MIG_LOGGER.write_log('WRLTN01',i_mrec.XXXXX,'The guarantor relationship cannot be transferred. i_mrec.XXXXX='||i_mrec.XXXXX);
                                                   o_sr_relation_cd    :=NULL;
        end case;
        return o_sr_relation_cd;
    end;


    /*---------- QA004.Destination list  ----------*/
    procedure get_adjust_data_indivisually(
        i_mrec             in     mdb.m_doctor%rowtype,   --> MDB.M_DOCTOR type record(s)
        o_fac_cd           out    varchar2,               --< Faculty code
        o_dpt_cd           out    varchar2,               --< Department code(s)
        o_div_cd           out    varchar2,               --< Course code(s)
        o_lab_cd           out    varchar2,               --< Field/Area code(s)
        o_match            out    varchar2                --< XXXXX
   )
   is
   begin
       o_match:='no';
       if(false) then
         null;
        /* Automatically generated source section START */
       elsif(i_mrec.XXXXX='XXXX0014') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0042';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0001') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0002') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0003') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0004') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0005') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0006') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0007') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0008') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0009') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0010') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0012') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0013') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0014') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0015') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX001') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0042'; o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '';o_lab_cd:= '';      o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '';    o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0021') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '';    o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0031') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '';    o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0041') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '11';o_lab_cd:= '';    o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0042') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0271';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0096') then o_fac_cd:= '41';o_dpt_cd:= '01';o_div_cd:= '46';o_lab_cd:= '0281';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0031') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0041') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0051') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0060') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0070') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0080') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0090') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0100') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0110') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0121') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0131') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0140') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0151') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1011') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1020') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1040') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1051') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1061') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1081') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1100') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0010') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0030') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0050') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0060') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0071') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0080') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0090') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0100') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1011') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1021') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1031') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1051') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1061') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1070') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1081') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1090') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1100') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1120') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1130') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1141') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1150') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1171') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1180') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1190') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0030') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0041') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0051') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '9999';  o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0061') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0071') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0081') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0090') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0101') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0111') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0120') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0130') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1011') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1020') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1080') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1090') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1100') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '9999';  o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1121') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1131') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1140') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1150') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1170') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0040') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0071') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0101') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0120') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0151') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0160') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0181') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0190') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1090') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1111') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1170') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0030') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0040') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0050') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0061') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0080') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0090') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0110') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0130') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0140') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0160') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1040') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1130') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1150') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1200') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1251') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX5011') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX5021') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0021') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0030') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0041') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0051') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0071') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0110') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0121') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0140') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0170') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0180') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0201') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1030') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1140') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1170') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1200') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX5020') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX5031') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0051') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0061') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0171') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX5111') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '9999';  o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1241') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '9999';  o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0010') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0030') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1010') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1021') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1060') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0010') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0030') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0041') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0061') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0070') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0081') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0090') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1010') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1021') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0021') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0030') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0040') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0051') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0060') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0071') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0080') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0090') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0100') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0111') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1011') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1021') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1040') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1051') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0030') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0051') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0060') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0010') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0041') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0061') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0070') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0081') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0091') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0100') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0110') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0101';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1040') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1050') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0081';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX5020') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0041') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0090') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0041';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0101') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX1061') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '9999';  o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0010') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '9999';  o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0021') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '9999';  o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX5120') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '28';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0021') then o_fac_cd:= '28';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0031') then o_fac_cd:= '28';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0010') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0031') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0040') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0071') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0081') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0091') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0110') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0121') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0131') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0141') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0151') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0161') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0171') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0181') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0191') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0201') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0211') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0221') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0231') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0241') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0251') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0261') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0271') then o_fac_cd:= '26';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0320') then o_fac_cd:= '28';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0010') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '9999';  o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0021') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0030') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '9999';  o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0041') then o_fac_cd:= '26';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0011') then o_fac_cd:= '28';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0020') then o_fac_cd:= '29';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0071';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0031') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0040') then o_fac_cd:= '28';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0010') then o_fac_cd:= '25';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0051';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0021') then o_fac_cd:= '26';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0031') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0040') then o_fac_cd:= '25';o_dpt_cd:= '02';o_div_cd:= '01';o_lab_cd:= '0021';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0050') then o_fac_cd:= '26';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0061') then o_fac_cd:= '25';o_dpt_cd:= '';o_div_cd:= '';o_lab_cd:= '';        o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0601') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0602') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '02';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0603') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX5601') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '03';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0601') then o_fac_cd:= '23';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0031';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0602') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0011';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0601') then o_fac_cd:= '61';o_dpt_cd:= '01';o_div_cd:= '01';o_lab_cd:= '0001';o_match:='yes';
       elsif(i_mrec.XXXXX='XXXX0602') then o_fac_cd:= '51';o_dpt_cd:= '01';o_div_cd:= '06';o_lab_cd:= '0002';o_match:='yes';
   
       end if;   
   end;




end;
/
