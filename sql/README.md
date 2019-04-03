## Important Files
<code>schema.sql</code> contains all the SQL necessary to instantiate the database schema

<code>mock_data.sql</code> is the main data file -- it contains all the insert statements necessary to populate the database schema.

<code>dml.sql</code> contains the SQL DML commands to implement the database functionality

### Other Notes
Running <code>combine_schema.sh</code> will overwrite <code>schema.sql</code> with an up-to-date version of the disparate SQL schema files. The script will order the tables in a way to resolve the referential dependencies, and will also build in the triggers from <code>triggers.sql</code>
