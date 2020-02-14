/* Copy Right 2020 Kentaro Kurose */


/* Sample script for Automated Certification Issue Machine in University */
/* Just a sample source and does'nt work by itself */
/* Dare to use magic number                         */

create or replace package XXXXX.cd2name

is
function resident(
    i_cd in varchar2             --コード
) return varchar2;

function elder(
    i_cd in varchar2             --コード
) return varchar2;

function relation(
    i_cd in varchar2             --コード
) return varchar2;

end;


/

create or replace package body XXXXX.cd2name
is

function resident(
    i_cd in varchar2             
) return varchar2
is
    cursor c1 is
        select name
        from   resident
        where  resident_cd = i_cd
        ;
    c1_rec c1%rowtype := null ;
    r_name XXXXX.resident.name%type;
begin
    open c1;
    fetch c1 into c1_rec;
    if(c1%found) then
        r_name:=c1_rec.name;
    end if;
    close c1;
    return r_name;
end;

function elder(
    i_cd in varchar2           
) return varchar2
is
    cursor c1 is
        select name
        from   elder
        where  elder_cd = i_cd
        ;
    c1_rec c1%rowtype := null ;
    r_name XXXXX.elder.name%type;
begin
    open c1;
    fetch c1 into c1_rec;
    if(c1%found) then
        r_name:=c1_rec.name;
    end if;
    close c1;
    return r_name;
end;

function relation(
    i_cd in varchar2             
) return varchar2
is
    cursor c1 is
        select name
        from   relation
        where  relation_cd = i_cd
        ;
    c1_rec c1%rowtype := null ;
    r_name XXXXX.relation.name%type;
begin
    open c1;
    fetch c1 into c1_rec;
    if(c1%found) then
        r_name:=c1_rec.name;
    end if;
    close c1;
    return r_name;
end;


end;


/
