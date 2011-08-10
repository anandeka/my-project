CREATE OR REPLACE FUNCTION getContractDocuments (pContractNo number)
   RETURN VARCHAR2
IS
    
    cursor cr_documents         
    IS
    
    select (PCDD.DOC_ID || '  ' || PCDD.DOC_TYPE) as DOC_DETAILS
    from PCDD_DOCUMENT_DETAILS pcdd,PCM_PHYSICAL_CONTRACT_MAIN pcm
    where PCM.INTERNAL_CONTRACT_REF_NO = PCDD.INTERNAL_CONTRACT_REF_NO
    and PCDD.IS_ACTIVE = 'Y'   
    AND pcm.internal_contract_ref_no = pContractNo;
     
    
   contract_docs  VARCHAR2(4000) :=''; 
   begin
            for documents in cr_documents
            loop    
                contract_docs:= contract_docs || documents.DOC_DETAILS || chr(10);
            end loop;
           
            return  contract_docs;
    end; 
/

