/* Miljan delete,update,insert */


/* --- DELETE --- */

create trigger Racun_delete
ON Racun
instead of delete
as
begin
if exists (select 1 from Predmeti where [Predmet_id] = (select [Predmet_id] from deleted))
			
			begin
				RAISERROR ('NIJE DOBRO POPUNJEN PK',1,1)
				rollback transaction
				return
				end

if exists (select 1 from Klijenti where [Klijent_id] = (select [Klijent_id] from deleted))
			begin
				RAISERROR ('NIJE DOBRO POPUNJEN PK',1,1)
				rollback transaction
				return
				end


if exists (select 1 from Advokat
			where [Advokat_id] = (select [Advokat_id] from deleted))
			
			begin
				RAISERROR ('NIJE DOBRO POPUNJEN PK',1,1)
				rollback transaction
				return
				end
		end



/* --- UPDATE --- */

CREATE TRIGGER Racun_update
ON [dbo].[Debit]
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE 
            i.Predmet_id IS NULL OR 
            i.Racun_Id IS NULL OR 
            i.stavkePredmeta_Id IS NULL OR 
            i.Advokat_Id IS NULL
    )
    BEGIN
        RAISERROR ('NIJE DOBRO POPUNJEN PK: Some PK values are NULL', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    UPDATE [dbo].[Debit]
    SET 
        Predmet_id = i.Predmet_id,
        Racun_Id = i.Racun_Id,
        stavkePredmeta_Id = i.stavkePredmeta_Id,
        Advokat_Id = i.Advokat_Id
    FROM 
        [dbo].[Debit] d
    INNER JOIN 
        inserted i ON d.[racudID] = i.[racudID] 
end





CREATE OR ALTER trigger Racun_insert
ON Racun
instead of insert
as
begin
    if exists (
        select i.Predmet_id, i.Racun_Id, i.stavkePredmeta_Id,i.Klijent  /*Moze i zvezdica ali najbolje je reci sta zelis (da bi bilo bolje optimizovano da dusan ne pravi problem :) */ 
        from inserted i where 
            i.Predmet_id is null or 
            i.Racun_Id is null or 
            i.stavkePredmeta_Id is null or 
            i.Klijent is null
    )
    begin
        RAISERROR ('NIJE DOBRO POPUNJEN PK: Some PK values are NULL or 0', 16, 1)
        rollback transaction
        return
    end

    if exists (
        select 1 
        from inserted i
		inner join Racun r on i.Racun_Id = r.Racun_Id
		)
    begin
        RAISERROR ('NIJE DOBRO POPUNJEN PK it already exists', 16, 1)
        rollback transaction
        return
    end


	insert /*Posle se radi normaln insert nece vam traziti*/
end


/* --- Klasterisani indeks --- */

CREATE CLUSTERED INDEX IX_DEBIT 
ON [dbo].[Racun] (Predmet_id, Racun_Id, stavkePredmeta_Id, Advokat_Id);
