module projections.profile.changeemail;

import std.stdio;
import std.variant;

import relationaldb.all;
import helpers.helperfactory;
import commands.changeemail;

class ChangeEmailProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private ChangeEmailMeta meta;

    this(
        RelationalDBInterface relationalDb,
        ChangeEmailMeta meta
    ) {
        this.relationalDb = relationalDb;
        this.meta = meta;
    }

    void handleEvent() {
        this.changeEmail();
    }

    private void changeEmail() {

        string sql = "
                UPDATE 
                    usr 
                SET 
                    email = ?
                WHERE
                    usrId = ?
            ";

        this.relationalDb.execute(sql, variantArray(
            this.meta.emailAddress,
            this.meta.usrId
        ));
    }       
}