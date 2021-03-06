module command.abstractdecisionmaker;

import vibe.vibe;
import container;
import command.all;
import commandrouter;

abstract class AbstractDecisionMaker
{
    protected bool executeCommandsAsyncronously;
    protected CommandRouter router;

    protected void throwExceptionIfNecessary() @safe
    {

    }

    public void executeCommands(Container container, CommandBusInterface commandBus) @safe
    {
        if (commandBus.size == 0) {
            throw new Exception("Decision maker issued no commands - this should never happen");
        }	 

        // Get CommandDispatcher (make a method in the container?)       
        auto dispatcher = new CommandDispatcher();
		this.router = new CommandRouter(container);
        dispatcher.attachListener(this.router);

        if (this.executeCommandsAsyncronously) {
            auto executeTask = runTask({
                commandBus.dispatch(dispatcher);
            });
        } else {
            commandBus.dispatch(dispatcher);
            this.throwExceptionIfNecessary();
        }
    }
}