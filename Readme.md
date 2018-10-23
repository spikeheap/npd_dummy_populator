# NPD dummy sample generator

This project generates dummy values to allow users to create a safe, random dataset which "looks" like the National Pupil Database. 

This tool was used for user research and testing as part of the DfE National Pupil Database Access Alpha.

## Prerequisites
- [Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads). Note: the developer edition and SSMS are available free of charge (for non-production use only).
- [FreeTDS](http://www.freetds.org), which can be installed with Homebrew on Mac.
- Ruby 2.5.1 or newer
- A copy of the NPD schema for `Repository_Live`.

## Usage

1. Create a `.env` file with `MSSQL_PASSWORD=SECURE_PASSWORD` (replacing `SECURE_PASSWORD` with your database password for the `sa` user). Optionally, update `app.rb` to change the username.
2. Run `bundle install` to install the Ruby dependencies.
3. Run `bundle exec ruby app.rb` to insert 500 pupils.

## Querying the data

You can look at the populated pupils with:

```sql
SELECT * FROM dbo.n_KS2_Pupil;
```

## Backing up the database (once it's been populated)

To create a backup run the following SQL:

```sql
BACKUP DATABASE [Repository_Live]
TO
  DISK = N'/var/opt/mssql/data/repository_live_dump.bak'
WITH
  NAME = N'Repository_Live',
  FORMAT,
  STATS = 5,
  COMPRESSION
```

If you're running SQL Server within Docker, you can copy the backup out using something like:

```bash
docker cp <container_id>:/var/opt/mssql/data/repository_live_dump.bak dumps/
```