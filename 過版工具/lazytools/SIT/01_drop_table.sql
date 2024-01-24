DECLARE
	sql_str varchar;
	rec record;
BEGIN

    FOR rec IN (SELECT 'DROP TABLE IF EXISTS ' || schemaname || '.' || tablename || ' CASCADE;' AS sql_str 
	  			  FROM pg_tables 
	             WHERE schemaname = 'abs_global')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
    
    FOR rec IN (SELECT 'DROP PACKAGE IF EXISTS ' || schema_name || '.' || object_name || ';' AS sql_str 
	  			  FROM all_objects 
				  WHERE schema_name= 'ABS_GLOBAL' 
				  AND object_type = 'PACKAGE')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
    
    FOR rec IN (SELECT 'DROP TYPE IF EXISTS ' || schema_name || '.' || object_name || ' CASCADE;' AS sql_str 
	  			  FROM all_objects 
				  WHERE schema_name= 'ABS_GLOBAL' 
				  AND object_type = 'TYPE')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
    
	FOR rec IN (SELECT 'DROP TABLE IF EXISTS ' || schemaname || '.' || tablename || ' CASCADE;' AS sql_str 
	  			  FROM pg_tables 
	             WHERE schemaname = 'abs_hk')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
    
    FOR rec IN (SELECT 'DROP PACKAGE IF EXISTS ' || schema_name || '.' || object_name || ';' AS sql_str 
	  			  FROM all_objects 
				  WHERE schema_name= 'ABS_HK' 
				  AND object_type = 'PACKAGE')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
    
    FOR rec IN (SELECT 'DROP TYPE IF EXISTS ' || schema_name || '.' || object_name || ' CASCADE;' AS sql_str 
	  			  FROM all_objects 
				  WHERE schema_name= 'ABS_HK' 
				  AND object_type = 'TYPE')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;

    FOR rec IN (SELECT 'DROP FUNCTION IF EXISTS ' || schema_name || '.' || object_name || ';' AS sql_str 
	  			  FROM all_objects 
				  WHERE schema_name= 'ABS_HK' 
				  AND object_type = 'FUNCTION')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
    
    FOR rec IN (SELECT 'DROP TABLE IF EXISTS ' || schemaname || '.' || tablename || ' CASCADE;' AS sql_str 
	  			  FROM pg_tables 
	             WHERE schemaname = 'abs_ods_global')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
    
    FOR rec IN (SELECT 'DROP PACKAGE IF EXISTS ' || schema_name || '.' || object_name || ';' AS sql_str 
	  			  FROM all_objects 
				  WHERE schema_name= 'ABS_ODS_GLOBAL' 
				  AND object_type = 'PACKAGE')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
    
    FOR rec IN (SELECT 'DROP TABLE IF EXISTS ' || schemaname || '.' || tablename || ' CASCADE;' AS sql_str 
	  			  FROM pg_tables 
	             WHERE schemaname = 'abs_ods_hk')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
    
    FOR rec IN (SELECT 'DROP PACKAGE IF EXISTS ' || schema_name || '.' || object_name || ';' AS sql_str 
	  			  FROM all_objects 
				  WHERE schema_name= 'ABS_ODS_HK' 
				  AND object_type = 'PACKAGE')
	LOOP
		EXECUTE IMMEDIATE rec.sql_str;
	END LOOP;
END;