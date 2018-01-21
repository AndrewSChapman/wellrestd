module commands.updateuser;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;

struct UpdateUserMeta
{
    long usrId;
    string firstName;
    string lastName;
}

class UpdateUserCommand : AbstractEvent!UpdateUserMeta,StorableEvent
{
    this(UpdateUserMeta meta)
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto updateUserMeta = *metadata.peek!(UpdateUserMeta);
        return new StorageEvent(typeid(this), lifecycle, updateUserMeta.serializeToJson());       
    }
}