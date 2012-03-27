
set define off;
update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = '{call generatePriceFixationDocument(?,?,?,?)}' where DGM.DGM_ID='DGM-PFD-1' and DGM.DOC_ID='CREATE_PRICE_FIXATION';