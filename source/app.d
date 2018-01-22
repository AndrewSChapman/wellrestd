// Third party imports
import std.stdio;
import vibe.vibe;
import dini;
import std.conv;

// Our imports
import appconfig;
import api.handlers.all;

// Global objects
AppConfig appConfig;

void main()
{
	appConfig = loadAppConfig();

	auto router = new URLRouter;
	router.registerRestInterface(new AuthHandler(appConfig));
    router.registerRestInterface(new ProfileHandler(appConfig));

    auto settings = new HTTPServerSettings;
	settings.port = appConfig.getServerListenPort();
    settings.bindAddresses = ["::1", "127.0.0.1", appConfig.getServerListenIP()];
	settings.errorPageHandler = delegate(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo errorInfo) {

		struct APIResponse
		{
			uint code;
			string message;
			string info;
		}

		APIResponse response;
		response.code = errorInfo.code;
		response.message = errorInfo.message;

		if (errorInfo.exception !is null) {
			response.info = errorInfo.exception.msg;
		}

		res.writeBody(response.serializeToJsonString());
	};	

	listenHTTP(settings, router);
	runApplication();

    logInfo(format("Server listening at http://%s:%d/", appConfig.getServerListenIP(), appConfig.getServerListenPort()));
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody("Hello, World!");
}

AppConfig loadAppConfig()
{
	// Load the ini config
	auto ini = Ini.Parse("config.ini");

	// Read in all the configurables into variables
	string serverListenIP = ini["Server"].getKey("listenIP");
	ushort serverListenPort = to!ushort(ini["Server"].getKey("listenPort"));

	long sessionTimeout = to!long(ini["Sessions"].getKey("timeoutInSeconds"));

    string relationalDbHost = ini["MySQL"].getKey("host");
    ushort relationalDbPort = to!ushort(ini["MySQL"].getKey("port"));
    string relationalDbUsername = ini["MySQL"].getKey("user");
    string relationalDbPassword = ini["MySQL"].getKey("password");
    string relationalDbName = ini["MySQL"].getKey("database");

    string mongoHost = ini["Mongo"].getKey("host");
    string mongoDbName = ini["Mongo"].getKey("dbName");
    string mongoCollectionName = ini["Mongo"].getKey("eventCollectionName");

    string redisHost = ini["Redis"].getKey("host");
    ushort redisPort = to!ushort(ini["Redis"].getKey("port"));
    uint redisDbNo = to!uint(ini["Redis"].getKey("dbNo"));

    string SMTPHost = ini["SMTP"].getKey("host");
    ushort SMTPPort = to!ushort(ini["SMTP"].getKey("port"));
    string SMTPUsername = ini["SMTP"].getKey("username");
    string SMTPPassword = ini["SMTP"].getKey("password");

    EventStoreEngineType eventStoreEngineType = EventStoreEngineType.MySQL;

    switch (ini["EventStore"].getKey("engine")) {
        case "MySQL":
            eventStoreEngineType = EventStoreEngineType.MySQL;
            break;

        case "Mongo":
            eventStoreEngineType = EventStoreEngineType.Mongo;
            break;            

        default:
            eventStoreEngineType = EventStoreEngineType.MySQL;
            break;

    }

	AppConfig appConfig = new AppConfig(
        serverListenIP,
        serverListenPort,
        sessionTimeout,
        relationalDbHost,
        relationalDbPort,
        relationalDbUsername,
        relationalDbPassword,
        relationalDbName,
        mongoHost,
        mongoDbName,
        mongoCollectionName,
        redisHost,
        redisPort,
        redisDbNo,
        SMTPHost,
        SMTPPort,
        SMTPUsername,
        SMTPPassword,
        eventStoreEngineType
	);

	return appConfig;
}