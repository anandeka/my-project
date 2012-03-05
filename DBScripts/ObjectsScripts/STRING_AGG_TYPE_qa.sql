create or replace type "STRING_AGG_TYPE" as object
(
  total varchar2(4000),
  static function odciaggregateinitialize(sctx in out string_agg_type)
    return number,

  member function odciaggregateiterate(self  in out string_agg_type,
                                       value in varchar2) return number,

  member function odciaggregateterminate(self        in string_agg_type,
                                         returnvalue out varchar2,
                                         flags       in number)
    return number,

  member function odciaggregatemerge(self in out string_agg_type,
                                     ctx2 in string_agg_type) return number
)
;
/
create or replace type body "STRING_AGG_TYPE" is
  static function odciaggregateinitialize(sctx in out string_agg_type)
    return number is
  begin
    sctx := string_agg_type(null);
    return odciconst.success;
  end;

  member function odciaggregateiterate(self  in out string_agg_type,
                                       value in varchar2) return number is
  begin
    if length(self.total || value) < 4000 then
      if instr(self.total, value || ',') <> 0 then
        self.total := self.total;
      else
        self.total := self.total || value || ',';
      end if;
    else
      self.total := self.total;
    end if;
    return odciconst.success;
  end;

  member function odciaggregateterminate(self        in string_agg_type,
                                         returnvalue out varchar2,
                                         flags       in number) return number is
  begin
    returnvalue := ltrim(self.total, ',');
    return odciconst.success;
  end;

  member function odciaggregatemerge(self in out string_agg_type,
                                     ctx2 in string_agg_type) return number is
  begin
    self.total := self.total || ctx2.total;
    return odciconst.success;
  end;
end;
/
