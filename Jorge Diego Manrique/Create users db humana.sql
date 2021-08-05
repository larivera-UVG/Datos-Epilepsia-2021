#drop user adm;
#drop user sec1;
#drop user sec2;

create user if not exists adm identified by '1234';
grant all privileges on humana.analisis to adm;
grant all privileges on humana.pacientes to adm;
grant all privileges on humana.pruebas to adm;
grant all privileges on humana.pruebas_datos to adm;
grant all privileges on humana.resultados_analisis to adm;
grant all privileges on humana.paciente_datos_personales to adm;

create user if not exists sec1 identified by '1234';
grant all privileges on humana.analisis to sec1;
grant all privileges on humana.pacientes to sec1;
grant all privileges on humana.pruebas to sec1;
grant all privileges on humana.pruebas_datos to sec1;
grant all privileges on humana.resultados_analisis to sec1;

create user if not exists sec2 identified by '1234';
grant select on humana.analisis to sec2;
grant select on humana.pacientes to sec2;
grant select on humana.pruebas to sec2;
grant select on humana.pruebas_datos to sec2;
grant select on humana.resultados_analisis to sec2;

show grants for adm;
show grants for sec1;
show grants for sec2;