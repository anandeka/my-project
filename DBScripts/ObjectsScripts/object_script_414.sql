ALTER TABLE DHD_DOCUMENT_HEADER_DETAILS ADD SPECIAL_INSTRUCTIONS2 CLOB;
UPDATE DHD_DOCUMENT_HEADER_DETAILS SET SPECIAL_INSTRUCTIONS2 = SPECIAL_INSTRUCTIONS;
ALTER TABLE DHD_DOCUMENT_HEADER_DETAILS DROP COLUMN SPECIAL_INSTRUCTIONS;
ALTER TABLE DHD_DOCUMENT_HEADER_DETAILS RENAME COLUMN SPECIAL_INSTRUCTIONS2 TO SPECIAL_INSTRUCTIONS;