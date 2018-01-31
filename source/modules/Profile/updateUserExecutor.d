module executors.profile.updateuser;

import std.stdio;
import std.variant;

import relationaldb.all;
import helpers.helperfactory;
import commands.updateuser;

class UpdateUserExecutor
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private UpdateUserCommandMetadata meta;

    this(
        RelationalDBInterface relationalDb,
        UpdateUserCommandMetadata meta
    ) {
        this.relationalDb = relationalDb;
        this.meta = meta;
    }

    void executeCommand() {
        this.updateUser();
    }

    private void updateUser() {

        string sql = "
                UPDATE usr SET 
                firstName = ?,
                lastName = ?
                WHERE usrId = ?
            ";

        this.relationalDb.execute(sql, variantArray(
            this.meta.firstName,
            this.meta.lastName,
            this.meta.usrId
        ));
    }       
}