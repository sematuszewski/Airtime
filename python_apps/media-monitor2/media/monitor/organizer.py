# -*- coding: utf-8 -*-
import media.monitor.pure   as mmp
import media.monitor.owners as owners
from media.monitor.handler    import ReportHandler
from media.monitor.log        import Loggable
from media.monitor.exceptions import BadSongFile
from media.monitor.events     import OrganizeFile
from pydispatch               import dispatcher
from os.path                  import dirname
import os.path

class Organizer(ReportHandler,Loggable):
    """
    Organizer is responsible to to listening to OrganizeListener events
    and committing the appropriate changes to the filesystem. It does
    not in any interact with WatchSyncer's even when the the WatchSyncer
    is a "storage directory". The "storage" directory picks up all of
    its events through pyinotify. (These events are fed to it through
    StoreWatchListener)
    """

    # Commented out making this class a singleton because it's just a band aid
    # for the real issue. The real issue being making multiple Organizer
    # instances with pydispatch

    #_instance = None
    #def __new__(cls, channel, target_path, recorded_path):
        #if cls._instance:
            #cls._instance.channel       = channel
            #cls._instance.target_path   = target_path
            #cls._instance.recorded_path = recorded_path
        #else:
            #cls._instance = super(Organizer, cls).__new__( cls, channel,
                    #target_path, recorded_path)
        #return cls._instance

    def __init__(self, channel, target_path, recorded_path):
        self.channel       = channel
        self.target_path   = target_path
        self.recorded_path = recorded_path
        super(Organizer, self).__init__(signal=self.channel, weak=False)

    def handle(self, sender, event):
        """
        Intercept events where a new file has been added to the organize
        directory and place it in the correct path (starting with
        self.target_path)
        """
        # Only handle this event type
        assert isinstance(event, OrganizeFile), \
            "Organizer can only handle OrganizeFile events.Given '%s'" % event
        try:
            # We must select the target_path based on whether file was recorded
            # by airtime or not.
            # Do we need to "massage" the path using mmp.organized_path?
            target_path = self.recorded_path if event.metadata.is_recorded() \
                                             else self.target_path
            # nasty hack do this properly
            owner_id = mmp.owner_id(event.path)
            if owner_id != -1:
                target_path = os.path.join(target_path, unicode(owner_id))

            mdata = event.metadata.extract()
            new_path = mmp.organized_path(event.path, target_path, mdata)

            # See hack in mmp.magic_move
            def new_dir_watch(d):
                # TODO : rewrite as return lambda : dispatcher.send(...
                def cb():
                    dispatcher.send(signal="add_subwatch", sender=self,
                            directory=d)
                return cb

            mmp.magic_move(event.path, new_path,
                    after_dir_make=new_dir_watch(dirname(new_path)))

            # The reason we need to go around saving the owner in this ass
            # backwards way is bewcause we are unable to encode the owner id
            # into the file itself so that the StoreWatchListener listener can
            # detect it from the file
            owners.add_file_owner(new_path, owner_id )

            self.logger.info('Organized: "%s" into "%s"' %
                    (event.path, new_path))
        except BadSongFile as e:
            self.report_problem_file(event=event, exception=e)
        # probably general error in mmp.magic.move...
        except Exception as e:
            self.unexpected_exception( e )
            self.report_problem_file(event=event, exception=e)

