CREATE OR REPLACE PROCEDURE generateAmendContractOutputDoc (
   old_doc_id                    VARCHAR2,
   new_doc_id                    VARCHAR2,
   pc_internal_contract_ref_no   VARCHAR2
)
IS
   original_content        VARCHAR2 (4000) := '';
   acd_display_order       NUMBER (8, 2)   := '';
   acd_pre_content_text    VARCHAR2 (4000) := '';
   acd_post_content_text   VARCHAR2 (4000) := '';
   cos_doc_id              VARCHAR2 (15)   := '';

   CURSOR cr_amended
   IS
      SELECT   acd.section_name section_name, acd.field_name field_name,
               acd.contract_content contract_content,
               acd.display_order display_order,
               acd.field_layout_id field_layout_id,
               acd.pre_content_text_id pre_content_text_id,
               acd.post_content_text_id post_content_text_id,
               acd.pre_content_text pre_content_text,
               acd.post_content_text post_content_text,
               acd.is_custom_section is_custom_section,
               acd.is_footer_section is_footer_section,
               acd.is_amend_section is_amend_section,
               acd.is_print_reqd is_print_reqd, acd.print_type print_type,
               acd.is_changed is_changed
          FROM acs_amend_contract_summary acs,
               acd_amend_contract_details acd
         WHERE acs.internal_contract_ref_no = pc_internal_contract_ref_no
           AND acs.doc_id = acd.doc_id
           AND acs.doc_id = new_doc_id
           AND acs.doc_type = 'AMENDED'
      ORDER BY acd.display_order;
BEGIN
   SELECT seq_cont_op.NEXTVAL
     INTO cos_doc_id
     FROM DUAL;

   INSERT INTO cos_contract_output_summary
               (doc_id, doc_type, template_type, template_name,
                internal_doc_ref_no, ver_no, issue_date, is_amendment, status,
                created_by, created_date, updated_by, updated_date,
                cancelled_by, cancelled_date, send_date, received_date,
                internal_contract_ref_no, contract_ref_no, contract_type,
                corporate_id, contract_signing_date, approval_type,
                amendment_no, watermark, amendment_date, document_print_type)
      SELECT cos_doc_id, acs.doc_type, acs.template_type, acs.template_name,
             acs.internal_doc_ref_no, acs.ver_no, acs.issue_date,
             acs.is_amendment, acs.status, acs.created_by, acs.created_date,
             acs.updated_by, acs.updated_date, acs.cancelled_by,
             acs.cancelled_date, acs.send_date, acs.received_date,
             acs.internal_contract_ref_no, acs.contract_ref_no,
             acs.contract_type, acs.corporate_id, acs.contract_signing_date,
             acs.approval_type, acs.amendment_no, acs.watermark,
             acs.amendment_date, acs.document_print_type
        FROM acs_amend_contract_summary acs
       WHERE acs.doc_id = new_doc_id
         AND acs.internal_contract_ref_no = pc_internal_contract_ref_no;

   FOR amended_rec IN cr_amended
   LOOP
      BEGIN
         SELECT NVL (acd.contract_content, 'NA'), acd.display_order,
                acd.pre_content_text, acd.post_content_text
           INTO original_content, acd_display_order,
                acd_pre_content_text, acd_post_content_text
           FROM acs_amend_contract_summary acs,
                acd_amend_contract_details acd
          WHERE acs.internal_contract_ref_no = pc_internal_contract_ref_no
            AND acs.doc_id = acd.doc_id
            AND acs.doc_id = old_doc_id
            AND acd.section_name = amended_rec.section_name
            AND acd.field_name = amended_rec.field_name;
      EXCEPTION
         WHEN OTHERS
         THEN
            original_content := 'NA';
      END;

      IF (NVL (amended_rec.contract_content, 'NA') = original_content)
      THEN
         /*  dbms_output.put_line(amended_rec.contract_content || ' ' ||
         'Records are equal');*/
         INSERT INTO cod_contract_output_detail
                     (doc_id, display_order,
                      field_layout_id, section_name,
                      field_name, is_print_reqd,
                      pre_content_text_id,
                      post_content_text_id,
                      contract_content,
                      pre_content_text,
                      post_content_text,
                      is_custom_section,
                      is_footer_section,
                      is_amend_section, print_type,
                      is_changed
                     )
              VALUES (cos_doc_id, amended_rec.display_order,
                      amended_rec.field_layout_id, amended_rec.section_name,
                      amended_rec.field_name, amended_rec.is_print_reqd,
                      amended_rec.pre_content_text_id,
                      amended_rec.post_content_text_id,
                      amended_rec.contract_content,
                      amended_rec.pre_content_text,
                      amended_rec.post_content_text,
                      amended_rec.is_custom_section,
                      amended_rec.is_footer_section,
                      amended_rec.is_amend_section, amended_rec.print_type,
                      amended_rec.is_changed
                     );
      ELSE
         /*  dbms_output.put_line(amended_rec.contract_content || ' ' ||
         'Records are not equal');*/
         INSERT INTO cod_contract_output_detail
                     (doc_id, display_order, field_layout_id,
                      section_name, field_name, is_print_reqd,
                      pre_content_text_id, post_content_text_id,
                      contract_content, pre_content_text,
                      post_content_text, is_custom_section,
                      is_footer_section, is_amend_section, print_type,
                      is_changed, document_type
                     )
              VALUES (cos_doc_id, amended_rec.display_order + 0.1, NULL,
                      amended_rec.section_name, amended_rec.field_name, 'Y',
                      NULL, NULL,
                      original_content, acd_pre_content_text,
                      acd_post_content_text, 'N',
                      'N', 'N', 'FULL',
                      'N', 'ORIGINAL'
                     );

         INSERT INTO cod_contract_output_detail
                     (doc_id, display_order,
                      field_layout_id, section_name,
                      field_name, is_print_reqd,
                      pre_content_text_id,
                      post_content_text_id,
                      contract_content,
                      pre_content_text,
                      post_content_text,
                      is_custom_section,
                      is_footer_section,
                      is_amend_section, print_type,
                      is_changed, document_type
                     )
              VALUES (cos_doc_id, amended_rec.display_order + 0.2,
                      amended_rec.field_layout_id, amended_rec.section_name,
                      amended_rec.field_name, amended_rec.is_print_reqd,
                      amended_rec.pre_content_text_id,
                      amended_rec.post_content_text_id,
                      amended_rec.contract_content,
                      amended_rec.pre_content_text,
                      amended_rec.post_content_text,
                      amended_rec.is_custom_section,
                      amended_rec.is_footer_section,
                      amended_rec.is_amend_section, amended_rec.print_type,
                      amended_rec.is_changed, 'AMENDED'
                     );
      END IF;
   END LOOP;
END;
/
