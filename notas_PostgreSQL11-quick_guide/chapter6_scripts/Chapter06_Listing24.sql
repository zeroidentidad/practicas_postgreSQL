DROP TRIGGER IF EXISTS tr_check_hash ON files;
CREATE TRIGGER
tr_check_hash
BEFORE                           
INSERT OR UPDATE 
ON files                         
FOR EACH ROW                     
EXECUTE PROCEDURE f_tr_check_hash_plperl();
