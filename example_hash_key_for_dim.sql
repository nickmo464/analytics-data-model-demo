-- Instead of using a decoupled integer or a simple copy of the source system's 
--   primary key for the dimension key, which requires you to complete the 
--   loading of the dimension tables prior to loading the fact table,
--   you can use a hash of the source key and a source system identifier.
--  This enables you to load in parallel.  The hashdiff example field
--     is something that can be used to help identify changed records
--     when you're doing an insert-only approach.

select 
       md5(nvl(upper(trim(source_key::string)),'-1')
           ||';'|| source_system_id::string) as DIM_SAMPLE_HKEY
     , source_key as SOURCE_KEY
     , md5(                       source_key::string
           ||';'|| nvl(to_varchar(interesting_date)::date, 'yyyy-mm-dd'),'2100-01-01')
           ||';'|| nvl(upper(trim(interesting_number::string)),'-1')
           ||';'|| nvl(upper(trim(interesting_text::string)),'-1')
           ||';'|| nvl(to_varchar(source_update_date)::date, 'yyyy-mm-dd'),'2100-01-01')
          ) as hashdiff
     , interesting_date
     , interesting_number
     , interesting_text
     , source_update_date
     , now() as update_ts
  from source_system_table