/* Copy Right 2020 Kentaro Kurose */

/* Sample script for Studying Abroad Student in University */
/* Just a sample source and does'nt work by itself         */
/* Dare to use magic number                                */

create or replace package XXXXX.abroad_lib

is

function family_div(
    i_code in varchar2
) return varchar2;

function resident(
    i_code in varchar2
) return varchar2;

function exchange(
    i_code in varchar2
) return varchar2;

end;

/


create or replace package BODY XXXXX.abroad_lib
is

function family_div(
    i_code in varchar2
) return varchar2
is
    cursor c1 is select name from family_div where family_div_cd=i_code;
    c1_rec c1%rowtype;
begin
    if i_code is null then return null;
    end if;

    c1_rec := null;
    open c1;
    fetch c1 into c1_rec;
    close c1;
    return c1_rec.name;
end;

function resident(
    i_code in varchar2
) return varchar2
is
    cursor c1 is select name from resident where resident_cd=i_code;
    c1_rec c1%rowtype;
begin
    if i_code is null then return null;
    end if;

    c1_rec := null;
    open c1;
    fetch c1 into c1_rec;
    close c1;
    return c1_rec.name;
end;

function exchange(
    i_code in varchar2
) return varchar2
is
    cursor c1 is select name from exchange where exchange_cd=i_code;
    c1_rec c1%rowtype;
begin
    if i_code is null then return null;
    end if;

    c1_rec := null;
    open c1;
    fetch c1 into c1_rec;
    close c1;
    return c1_rec.name;
end;

end;

/
