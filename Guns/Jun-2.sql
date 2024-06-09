create trigger Debit_insert
on Debit
for insert
as
begin
if exists (select 1 from inserted where Racun_sifra is null)
	begin
		raiserror('Šifra računa ne sme biti null!',16,1)
		rollback transaction
		return
	end	
if exists (select 1 from inserted where Klijent_ID is null)
	begin
		raiserror('Klijent_ID ne sme biti null!',16,1)
		rollback transaction
		return
	end 
if exists (select 1 from inserted where predmet_sifra is null)
	begin
		raiserror('Šifra predmeta ne sme biti null!',16,1)
		rollback transaction
		return
	end

if not exists (select 1 from Klijenti where Klijent_sifra in (select Klijent_ID from inserted))
	begin
		raiserror('Referenca Klijent_ID nije validna!',16,1)
		rollback transaction
		return
	end
if not exists (select 1 from Predmeti where Predmet_sifra in (select predmet_sifra from inserted))
	begin
		raiserror('Referenca šifra predmeta nije validna!',16,1)
		rollback transaction
		return
	end

	insert into Debit(Racun_sifra,Klijent_ID,predmet_sifra,broj,tip,Datum,Zaduzenje,Uplaceno,Troskovi,Porez,Za_naplatu,valuta,Naziv,mesec,Placen,uzeto,Z_racun,Vlasnik)
	select Racun_sifra,Klijent_ID,predmet_sifra,broj,tip,Datum,Zaduzenje,Uplaceno,Troskovi,Porez,Za_naplatu,valuta,Naziv,mesec,Placen,uzeto,Z_racun,Vlasnik from inserted
end

insert into Debit (Racun_sifra,Klijent_ID,predmet_sifra,broj,tip,Datum,Zaduzenje,Uplaceno,Troskovi,Porez,Za_naplatu,valuta,Naziv,mesec,Placen,uzeto,Z_racun,Vlasnik)
values (null, 4055, 11111, '1-02', 1, '2002-04-02', '81450', '0', '0', '0', '0', 'Din', 'Baze podataka - napredni nivo', '6', '1', '1', null, 'Ilija Živadinović')
select * from Debit	 /* RADI */


/* --- Delete trigger --- */ 


create trigger Debit_delete
on Debit
for delete
as
begin

if exists (select 1 from Stavke where racun in (select racun from deleted))
	begin
		raiserror('Ne možete obrisati ovaj račun jer postoje stavke vezane za njega!',16,1)
		rollback transaction
		return
	end
if exists(select 1 from Troskovi where racun in (select racun from deleted))
	begin
		raiserror('Ne možete obrisati ovaj račun jer postoje troškovi vezni za njega!',16,1)
		rollback transaction
		return
	end

	delete from Debit
	where Racun_sifra in(select Racun_sifra from deleted);
end


delete from Debit where Racun_sifra = '4159/1-02'
select * from Debit  /* RADI */


/* --- Debit update --- */


create trigger Debit_update 
on Debit
for update
as
begin

if exists (select 1 from inserted i where i.Klijent_ID is null or i.predmet_sifra is null)
	begin
		raiserror('Ne možete uneti vrednost NULL u polje!',16,1)
		rollback transaction
		return
	end

	update Debit
	set Klijent_ID = i.Klijent_ID, predmet_sifra = i.predmet_sifra
	from Debit d inner join inserted i on d.Racun_sifra = i.Racun_sifra		/* ? */
end  



create clustered index ix_Jun
on Debit (predmet_sifra);

select * from Debit where predmet_sifra = '4159'