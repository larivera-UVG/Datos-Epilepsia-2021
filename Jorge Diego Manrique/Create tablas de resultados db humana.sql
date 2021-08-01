use humana;

create table if not exists analisis(
	id int not null auto_increment,
	id_analisis int not null,
	fecha_analisis date not null,
	realizado_por varchar(50) not null,
	tipo_analisis varchar(20) not null,
	id_paciente int not null,
	id_prueba int not null,
	primary key (id),
	#constraint fk_pdatos foreign key (id_prueba) references pruebas(id_prueba)
);

create table if not exists resultados_analisis(
	id int not null auto_increment,
	id_analisis int not null,
	primary key (id)
);