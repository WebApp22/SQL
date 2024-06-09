create trigger Debit_insert
on Debit
for insert 
as 
begin 

if exists (select 1 from inserted where Racun_sifra is null)
	begin
		raiserror('Šifra računa ne može biti null',16,1)
		rollback transaction
		return
	end

if not exists (select 1 from Predmeti where Predmet_sifra in (select predmet_sifra from inserted))
	begin 
		raiserror('Referenca nije validna!',16,1)
		rollback transaction
		return
	end

insert into Debit(Racun_sifra, Klijent_ID, predmet_sifra, broj, tip, Datum, Zaduzenje, Uplaceno, Troskovi, Porez, Za_naplatu, valuta, Naziv, mesec, Placen, uzeto, Z_racun, Vlasnik)
select Racun_sifra, Klijent_ID, predmet_sifra, broj, tip, Datum, Zaduzenje, Uplaceno, Troskovi, Porez, Za_naplatu, valuta, Naziv, mesec, Placen, uzeto, Z_racun, Vlasnik from inserted
end


/* Debit delete */

create trigger Debit_delete
on Debit
for delete
as 
begin

if exists (select 1 from Troskovi where racun in(select racun from deleted))
	begin
		raiserror('Ne možemo obrisati ovaj račun jer postoje trošokovi vezani za njega',16,1)
		rollback transaction
		return
	end

if exists (select 1 from Stavke where racun in (select racun from deleted))
	begin
		raiserror('Ne možemo obrisati ovaj račun jer postoje stavke vezane za njega',16,1)
		rollback transaction
		return
	end

delete from Debit
where Racun_sifra in(select Racun_sifra from deleted);
end

/* Debit update */ 

create trigger Debit_update
on Debit
for update
as
begin

if exists (select 1 from inserted i where i.Klijent_ID is null or i.predmet_sifra is null)
	begin 
		raiserror('Ne možete uneti NULL vrednost u polje',16,1)
		rollback transaction
		return
	end

	update Debit 
	set Klijent_ID = i.Klijent_ID, predmet_sifra = i.predmet_sifra
	from Debit d inner join inserted i on d.Racun_sifra = i.Racun_sifra
end
select * from Debit


create trigger Debit_updatee
on Debit
for update
as 
begin 

if exists (select 1 from inserted i where i.Klijent_ID is null or i.predmet_sifra is null)
	begin 
		raiserror('Ne možemo uneti vrednost NULL u polje',16,1)
		rollback transaction
		return
	end

	update Debit
	set Klijent_ID = i.Klijent_ID, predmet_sifra = i.predmet_sifra
	from Debit d inner join inserted i on d.Racun_sifra = i.Racun_sifra
end




/* ----------------- PREDMETI -------------------	*/

alter trigger Predmet_insert
on Predmeti
for insert
as
begin

/*if exists (select 1 from inserted where Predmet_sifra is null)
	begin
		raiserror('Šifra predmeta ne može biti null!',16,1)
		rollback transaction
		return
	end*/ -- Ovo je PredmetID --

if exists (select 1 from inserted where Klijent_sifra is null)
	begin
		raiserror('Šifra klijenta ne može biti null!',16,1)
		rollback transaction
		return
	end
if exists (select 1 from inserted where Advokat_sifra is null)
	begin
		raiserror('Šifra advokata ne može biti null!',16,1)
		rollback transaction
		return
	end

if not exists (select 1 from Klijenti where Klijent_sifra in (select Klijent_sifra from inserted)) 
	begin
		raiserror('Referenca šifra klijenta nije validna!',16,1)
		rollback transaction
		return
	end
if not exists (select 1 from Advokati where Sifra in (select Advokat_sifra from inserted))
	begin
		raiserror('Referenca šifra advokata nije validna!',16,1)
		rollback transaction
		return
	end

	insert into Predmeti(Predmet_br,Predmet_sifra,Naziv,Klijent_sifra,Fee_satnica,Tip,Valuta,Partner,Associate,Practice,Advokat_sifra,Advokat,Datum_otvaranja,Arhiva,ttip)
	select Predmet_br,Predmet_sifra,Naziv,Klijent_sifra,Fee_satnica,Tip,Valuta,Partner,Associate,Practice,Advokat_sifra,Advokat,Datum_otvaranja,Arhiva,ttip from inserted

end


insert into Predmeti(Predmet_br,Predmet_sifra,Naziv,Klijent_sifra,Fee_satnica,Tip,Valuta,Partner,Associate,Practice,Advokat_sifra,Advokat,Datum_otvaranja,Arhiva,ttip)
values 
(1,1111,'Neki naziv',4185,100,1,'Din',1, 0.75, 0.5, null, 'JV', '2001-12-22', 1, 1)

select * from Predmeti   /* RADI */
 


 /* Predmeti delete */


 create trigger Predmeti_delete
 on Predmeti
 for delete
 as
 begin

 if exists(select 1 from Stavke where Predmet_sifra in (select Predmet_sifra from deleted))
	begin
		raiserror('Ne možemo obrisati ovaj predmet jer postoje stavke vezane za njega!',16,1)
		rollback transaction
		return
	end
if exists (select 1 from Troskovi where predmet_ID in (select Predmet_sifra from deleted))
	begin 
		raiserror('Ne možemo obrisati ovaj predmet jer postoje troškovi vezani za njega!',16,1)
		rollback transaction
		return
	end
if exists (select 1 from Debit where predmet_sifra in (select Predmet_sifra from deleted))
	begin
		raiserror ('Ne možemo obrisati ovaj predmet jer postoje računi vezani za njega!',16,1)
		rollback transaction
		return
	end

	delete from Predmeti 
	where Predmet_sifra in (select Predmet_sifra from deleted)
end

delete Predmeti where Predmet_sifra = '4055/5'	/* RADI */

 select * from Troskovi
 select * from Stavke



 /* ----------------- TROSKOVI -------------------	*/

create trigger Troskovi_insert
on Troskovi
for insert
as 
begin

if exists (select 1 from inserted where predmet_ID is null)
	begin
		raiserror('Predmet_ID ne može biti null',16,1)
		rollback transaction
		return
	end

if not exists (select 1 from Predmeti where Predmet_sifra in (select predmet_ID from inserted))
	begin
		raiserror('Referenca nije validna!',16,1)
		rollback transaction
		return
	end

if exists (select 1 from inserted where racun is null)
	begin 
		raiserror('Racun ne može biti null',16,1)
		rollback transaction
		return
	end
if not exists (select 1 from Debit where Racun_sifra in (select racun from inserted))
	begin
		raiserror('Referenca nije validna!',16,1)
		rollback transaction
		return
	end

insert into Troskovi(predmet_ID,Opis,Vrednost,auto,Datum,valuta,tip,broj,racun,placeno,uzeto)
select predmet_ID,Opis,Vrednost,auto,Datum,valuta,tip,broj,racun,placeno,uzeto from inserted

end


/* Troškovi delete */

/* ? */



/* ----------------- STAVKE -------------------	*/

create trigger Stavke_insert
on Stavke
for insert
as 
begin

if exists (select 1 from inserted where Predmet_sifra is null)
	begin
		raiserror('Šifra predmeta ne može biti null',16,1)
		rollback transaction
		return
	end

if exists (select 1 from inserted where Advokat_sifra is null)
	begin
		raiserror('Šifra advokata ne može biti null',16,1)
		rollback transaction
		return
	end
if exists (select 1 from inserted where racun is null)
	begin
		raiserror('Račun ne može biti null',16,1)
		rollback transaction
		return
	end

if not exists (select 1 from Predmeti where Predmet_sifra in (select Predmet_sifra from inserted))
	begin
		raiserror('Referenca šifra predmeta  nije validna!',16,1)
		rollback transaction
		return
	end

if not exists (select 1 from Advokati where Sifra in (select Advokat_sifra from inserted))
	begin
		raiserror('Referenca šifra advokata nije validna!',16,1)
		rollback transaction
		return
	end
if not exists (select 1 from Debit where Racun_sifra in (select racun from inserted))
	begin
		raiserror('Referenca račun nije validna!',16,1)
		rollback transaction
		return
	end

insert into Stavke(Predmet_sifra,Red_br,Br,Datum,Opis,Advokat_sifra,Status,Utroseno_vreme,Satnina,tip,Obr_vrednost,broj,racun,placeno,arhiva,uzeto)
select Predmet_sifra,Red_br,Br,Datum,Opis,Advokat_sifra,Status,Utroseno_vreme,Satnina,tip,Obr_vrednost,broj,racun,placeno,arhiva,uzeto from inserted
end

/* Stavke delete */ 

/* ? */



/* Optimizacija upita na logičkom i fizičkom nivou */

CREATE NONCLUSTERED INDEX IX_JUN
ON Debit (predmet_sifra);

select * from Debit where predmet_sifra = '4159'