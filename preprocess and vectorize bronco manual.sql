--Create a database named hackathon
CREATE database HACKATHON;

--Creating Stage to place the manual(bronco.pdf)
CREATE STAGE EXTERNAL_STAGE;

--Use role account admin
use role accountadmin;

--Create a warehouse
CREATE OR REPLACE WAREHOUSE compute_wh
  WAREHOUSE_SIZE = 'XSMALL';

-- Place the Pdf file bronco.pdf in external stage
--'@"HACKATHON"."PUBLIC"."EXTERNAL_STAGE"/bronco.pdf'
-- This is being used in the stored procedure to load the table and vectorize content by page

--Load the pdf and vectorize it
CREATE OR REPLACE PROCEDURE preprocess_and_vectorize_data()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python','PyPDF2')
HANDLER = 'run'
AS
$$
from snowflake.snowpark.context import get_active_session
import PyPDF2
from snowflake.snowpark.files import SnowflakeFile
import re
import pandas as pd

def clean_text(text):
        # Replace multiple spaces with a single space
        text = re.sub(r'\s+', ' ', text)
        # Remove spaces before punctuation
        text = re.sub(r'\s+([?.!,])', r'\1', text)
        # Handle cases where there might be a space after a hyphen
        text = re.sub(r'-\s', '', text)
        return text.strip()

def run(session): 
    
    file_path='@"HACKATHON"."PUBLIC"."EXTERNAL_STAGE"/bronco.pdf'
    with SnowflakeFile.open(file_path, 'rb',require_scoped_url = False) as file:
            reader = PyPDF2.PdfFileReader(file)
            page_content_dict={}
            
            for page_num in range(reader.numPages):
                page = reader.getPage(page_num)
                text = page.extract_text()
                cleaned_text = clean_text(text)
                page_content_dict[page_num] = cleaned_text
    
    content_page_df = pd.DataFrame(list(page_content_dict.items()), columns=['page_number','content'])
    session.write_pandas(content_page_df, table_name='page_content_bronco', auto_create_table=True)
    
    query = '''select *,SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', "content") as vector_embeddings  from HACKATHON.PUBLIC."page_content_bronco" '''

    table_with_vectors=session.sql(query)
    table_with_vectors.write.mode("overwrite").save_as_table(table_name='BRONCO_PAGE_CONTENT_WITH_VECT_EMB')

    return "Manual Successfully loaded into table and vectorized"
$$;

--Call the stored procedure(One time Run)
call preprocess_and_vectorize_data();

--queries for looking tables(optional)
select * from hackathon.public.BRONCO_PAGE_CONTENT_WITH_VECT_EMB;

