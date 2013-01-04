/* Formatted on 2013/01/02 12:48 (Formatter Plus v4.8.8) */
UPDATE pfam_price_fix_action_mapping pfam
   SET pfam.is_active = 'N'
 WHERE pfam.pfam_id =
          (SELECT MAX (pfam.pfam_id)
             FROM pfam_price_fix_action_mapping pfam
            WHERE pfam.pfd_id IN (
                           SELECT   pfam.pfd_id
                               FROM pfam_price_fix_action_mapping pfam
                              WHERE pfam.is_active = 'Y'
                           GROUP BY pfam.pfd_id
                             HAVING COUNT (*) > 1))