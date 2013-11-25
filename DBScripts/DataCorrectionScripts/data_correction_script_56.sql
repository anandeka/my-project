--For BAT Corporate
--Update Formula Table
INSERT INTO ppf_phy_payable_formula
            (ppf_id, corporate_id, formula_name, external_formula, VERSION,
             is_active, internal_formula)
   SELECT ppf_id || 'BAT', 'BAT', formula_name, external_formula,
          VERSION, is_active, internal_formula
     FROM ppf_phy_payable_formula
    WHERE ppf_id IN (
             SELECT DISTINCT (pcepc.payable_formula_id)
                        FROM pcm_physical_contract_main pcm,
                             pcpch_pc_payble_content_header pcpch,
                             pcepc_pc_elem_payable_content pcepc
                       WHERE pcm.internal_contract_ref_no =
                                                pcpch.internal_contract_ref_no
                         AND pcpch.pcpch_id = pcepc.pcpch_id
                         AND pcm.corporate_id IN 'BAT'
                         AND pcm.is_active = 'Y'
                         AND pcpch.is_active = 'Y'
                         AND pcepc.is_active = 'Y');

--Update Contract Payable Content Table
UPDATE pcepc_pc_elem_payable_content pcepc
   SET pcepc.payable_formula_id = pcepc.payable_formula_id || 'BAT'
 WHERE pcepc.pcepc_id IN (
          SELECT pcepc.pcepc_id
            FROM pcm_physical_contract_main pcm,
                 pcpch_pc_payble_content_header pcpch,
                 pcepc_pc_elem_payable_content pcepc
           WHERE pcm.internal_contract_ref_no = pcpch.internal_contract_ref_no
             AND pcpch.pcpch_id = pcepc.pcpch_id
             AND pcm.corporate_id = 'BAT'
             AND pcm.is_active = 'Y'
             AND pcpch.is_active = 'Y'
             AND pcepc.is_active = 'Y');
             
             
             
--For BAM Corporate
--Update Formula Table
INSERT INTO ppf_phy_payable_formula
            (ppf_id, corporate_id, formula_name, external_formula, VERSION,
             is_active, internal_formula)
   SELECT ppf_id || 'BAM', 'BAM', formula_name, external_formula,
          VERSION, is_active, internal_formula
     FROM ppf_phy_payable_formula
    WHERE ppf_id IN (
             SELECT DISTINCT (pcepc.payable_formula_id)
                        FROM pcm_physical_contract_main pcm,
                             pcpch_pc_payble_content_header pcpch,
                             pcepc_pc_elem_payable_content pcepc
                       WHERE pcm.internal_contract_ref_no =
                                                pcpch.internal_contract_ref_no
                         AND pcpch.pcpch_id = pcepc.pcpch_id
                         AND pcm.corporate_id IN 'BAM'
                         AND pcm.is_active = 'Y'
                         AND pcpch.is_active = 'Y'
                         AND pcepc.is_active = 'Y');

--Update Contract Payable Content Table
UPDATE pcepc_pc_elem_payable_content pcepc
   SET pcepc.payable_formula_id = pcepc.payable_formula_id || 'BAM'
 WHERE pcepc.pcepc_id IN (
          SELECT pcepc.pcepc_id
            FROM pcm_physical_contract_main pcm,
                 pcpch_pc_payble_content_header pcpch,
                 pcepc_pc_elem_payable_content pcepc
           WHERE pcm.internal_contract_ref_no = pcpch.internal_contract_ref_no
             AND pcpch.pcpch_id = pcepc.pcpch_id
             AND pcm.corporate_id = 'BAM'
             AND pcm.is_active = 'Y'
             AND pcpch.is_active = 'Y'
             AND pcepc.is_active = 'Y');