-- updating pqcq where isDiductible is null

UPDATE pqca_pq_chemical_attributes pqca
   SET pqca.is_deductible = 'N'
 WHERE pqca.is_deductible IS NULL;