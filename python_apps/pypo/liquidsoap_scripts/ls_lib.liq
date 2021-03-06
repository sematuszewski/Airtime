def notify(m)
  #current_media_id := string_of(m['schedule_table_id'])
  command = "/usr/lib/airtime/pypo/bin/liquidsoap_scripts/notify.sh --data='#{!pypo_data}' --media-id=#{m['schedule_table_id']} &"
  log(command)
  system(command)
end

def notify_stream(m)
  json_str = string.replace(pattern="\n",(fun (s) -> ""), json_of(m))
  #if a string has a single apostrophe in it, let's comment it out by ending the string before right before it
  #escaping the apostrophe, and then starting a new string right after it. This is why we use 3 apostrophes.
  json_str = string.replace(pattern="'",(fun (s) -> "'\''"), json_str)
  command = "/usr/lib/airtime/pypo/bin/liquidsoap_scripts/notify.sh --webstream='#{json_str}' --media-id=#{!current_dyn_id} &"
  log(command)
  system(command)
end

# A function applied to each metadata chunk
def append_title(m) =  
  log("Using stream_format #{!stream_metadata_type}")
  if !stream_metadata_type == 1 then
    [("title", "#{!show_name} - #{m['artist']} - #{m['title']}")]
  elsif !stream_metadata_type == 2 then
    [("title", "#{!station_name} - #{!show_name}")]
  else
    [("title", "#{m['artist']} - #{m['title']}")]
  end
end

def crossfade_airtime(s)
  #duration is automatically overwritten by metadata fields passed in
  #with audio
  s = fade.in(type="log", duration=0., s)
  s = fade.out(type="log", duration=0., s)
  fader = fun (a,b) -> add(normalize=false,[b,a])
  cross(fader,s)
end

def transition(a,b) =
  log("transition called...")
  add(normalize=false,
     [ sequence([ blank(duration=0.01),
                   fade.initial(duration=!default_dj_fade, b) ]),
        fade.final(duration=!default_dj_fade, a) ])
end

# we need this function for special transition case(from default to queue)
# we don't want the trasition fade to have effect on the first song that would
# be played siwtching out of the default(silent) source
def transition_default(a,b) =
  log("transition called...")
  if !just_switched then
      just_switched := false
      add(normalize=false,
         [ sequence([ blank(duration=0.01),
                       fade.initial(duration=!default_dj_fade, b) ]),
            fade.final(duration=!default_dj_fade, a) ])
  else
    just_switched := false
    b
  end
end


# Define a transition that fades out the
# old source, adds a single, and then 
# plays the new source
def to_live(old,new) = 
  # Fade out old source
  old = fade.final(old)
  # Compose this in sequence with
  # the new source
  sequence([old,new])
end


def output_to(output_type, type, bitrate, host, port, pass, mount_point, url, description, genre, user, s, stream, connected, name, channels) =
    source = ref s
    def on_error(msg)
        connected := "false"
        system("/usr/lib/airtime/pypo/bin/liquidsoap_scripts/notify.sh --error='#{msg}' --stream-id=#{stream} --time=#{!time} &")
        log("/usr/lib/airtime/pypo/bin/liquidsoap_scripts/notify.sh --error='#{msg}' --stream-id=#{stream} --time=#{!time} &")
        5.
    end
    def on_connect()
        connected := "true"
        system("/usr/lib/airtime/pypo/bin/liquidsoap_scripts/notify.sh --connect --stream-id=#{stream} --time=#{!time} &")
        log("/usr/lib/airtime/pypo/bin/liquidsoap_scripts/notify.sh --connect --stream-id=#{stream} --time=#{!time} &")
    end

    stereo = (channels == "stereo")

    if output_type == "icecast" then
        user_ref = ref user
        if user == "" then
            user_ref := "source"
        end
        output_mono = output.icecast(host = host,
                    port = port,
                    password = pass,
                    mount = mount_point,
                    fallible = true,
                    url = url,
                    description = description,
                    name = name,
                    genre = genre,
                    user = !user_ref,
                    on_error = on_error,
                    on_connect = on_connect)

        output_stereo = output.icecast(host = host,
                    port = port,
                    password = pass,
                    mount = mount_point,
                    fallible = true,
                    url = url,
                    description = description,
                    name = name,
                    genre = genre,
                    user = !user_ref,
                    on_error = on_error,
                    on_connect = on_connect)
        if type == "mp3" then
            if bitrate == 24 then 
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 24, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 24, stereo = false), mean(!source)))
                end
            elsif bitrate == 32 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 32, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 32, stereo = false), mean(!source)))
                end
            elsif bitrate == 48 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 48, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 48, stereo = false), mean(!source)))
                end
            elsif bitrate == 64 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 64, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 64, stereo = false), mean(!source)))
                end
            elsif bitrate == 96 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 96, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 96, stereo = false), mean(!source)))
                end
            elsif bitrate == 128 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 128, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 128, stereo = false), mean(!source)))
                end
            elsif bitrate == 160 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 160, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 160, stereo = false), mean(!source)))
                end
            elsif bitrate == 192 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 192, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 192, stereo = false), mean(!source)))
                end
            elsif bitrate == 224 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 224, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 224, stereo = false), mean(!source)))
                end
            elsif bitrate == 256 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 256, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 256, stereo = false), mean(!source)))
                end
            elsif bitrate == 320 then
                if stereo then
                    ignore(output_stereo(%mp3(bitrate = 320, stereo = true), !source))
                else
                    ignore(output_mono(%mp3(bitrate = 320, stereo = false), mean(!source)))
                end
            end
        else
            if not icecast_vorbis_metadata then
                source := add(normalize=false, [amplify(0.00001, noise()), !source])
            end

            if bitrate == 24 or bitrate == 32 or bitrate == 48 then 
                if stereo then
                    ignore(output_stereo(%vorbis(quality=-0.1, channels = 2), !source))
                else
                    ignore(output_mono(%vorbis(quality=-0.1, channels = 1), mean(!source)))
                end
            elsif bitrate == 64 then
                if stereo then
                    ignore(output_stereo(%vorbis(quality=0, channels = 2), !source))
                else
                    ignore(output_mono(%vorbis(quality=0, channels = 1), mean(!source)))
                end
            elsif bitrate == 96 then
                if stereo then
                    ignore(output_stereo(%vorbis(quality=0.2, channels = 2), !source))
                else
                    ignore(output_mono(%vorbis(quality=0.2, channels = 1), mean(!source)))
                end
            elsif bitrate == 128 then
                if stereo then
                    ignore(output_stereo(%vorbis(quality=0.4, channels = 2), !source))
                else
                    ignore(output_mono(%vorbis(quality=0.4, channels = 1), mean(!source)))
                end
            elsif bitrate == 160 then
                if stereo then
                    ignore(output_stereo(%vorbis(quality=0.5, channels = 2), !source))
                else
                    ignore(output_mono(%vorbis(quality=0.5, channels = 1), mean(!source)))
                end
            elsif bitrate == 192 then
                if stereo then
                    ignore(output_stereo(%vorbis(quality=0.6, channels = 2), !source))
                else
                    ignore(output_mono(%vorbis(quality=0.6, channels = 1), mean(!source)))
                end
            elsif bitrate == 224 then
                if stereo then
                    ignore(output_stereo(%vorbis(quality=0.7, channels = 2), !source))
                else
                    ignore(output_mono(%vorbis(quality=0.7, channels = 1), mean(!source)))
                end
            elsif bitrate == 256 then
                if stereo then
                    ignore(output_stereo(%vorbis(quality=0.8, channels = 2), !source))
                else
                    ignore(output_mono(%vorbis(quality=0.8, channels = 1), mean(!source)))
                end
            elsif bitrate == 320 then
                if stereo then
                    ignore(output_stereo(%vorbis(quality=0.9, channels = 2), !source))
                else
                    ignore(output_mono(%vorbis(quality=0.9, channels = 1), mean(!source)))
                end
            end
        end
    else
        user_ref = ref user
        if user == "" then
            user_ref := "source"
        end
        
        description_ref = ref description
        if description == "" then
            description_ref := "N/A"
        end
        
        genre_ref = ref genre
        if genre == "" then
            genre_ref := "N/A"
        end
        
        url_ref = ref url
        if url == "" then
            url_ref := "N/A"
        end
        output.shoutcast_mono = output.shoutcast(id = "shoutcast_stream_#{stream}",
                    host = host,
                    port = port,
                    password = pass,
                    fallible = true,
                    url = !url_ref,
                    genre = !genre_ref,
                    name = !description_ref,
                    user = !user_ref,
                    on_error = on_error,
                    on_connect = on_connect)

        output.shoutcast_stereo = output.shoutcast(id = "shoutcast_stream_#{stream}",
                    host = host,
                    port = port,
                    password = pass,
                    fallible = true,
                    url = !url_ref,
                    genre = !genre_ref,
                    name = !description_ref,
                    user = !user_ref,
                    on_error = on_error,
                    on_connect = on_connect)

         if bitrate == 24 then 
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 24, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 24, stereo = false), mean(!source)))
                end
            elsif bitrate == 32 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 32, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 32, stereo = false), mean(!source)))
                end
            elsif bitrate == 48 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 48, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 48, stereo = false), mean(!source)))
                end
            elsif bitrate == 64 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 64, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 64, stereo = false), mean(!source)))
                end
            elsif bitrate == 96 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 96, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 96, stereo = false), mean(!source)))
                end
            elsif bitrate == 128 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 128, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 128, stereo = false), mean(!source)))
                end
            elsif bitrate == 160 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 160, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 160, stereo = false), mean(!source)))
                end
            elsif bitrate == 192 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 192, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 192, stereo = false), mean(!source)))
                end
            elsif bitrate == 224 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 224, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 224, stereo = false), mean(!source)))
                end
            elsif bitrate == 256 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 256, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 256, stereo = false), mean(!source)))
                end
            elsif bitrate == 320 then
                if stereo then
                    ignore(output.shoutcast_stereo(%mp3(bitrate = 320, stereo = true), !source))
                else
                    ignore(output.shoutcast_mono(%mp3(bitrate = 320, stereo = false), mean(!source)))
                end
            end
    end
end

# Add a skip function to a source
# when it does not have one
# by default
def add_skip_command(s)
 # A command to skip
  def skip(_)
    # get playing (active) queue and flush it
    l = list.hd(server.execute("queue.secondary_queue"))
    l = string.split(separator=" ",l)
    list.iter(fun (rid) -> ignore(server.execute("queue.remove #{rid}")), l)

    l = list.hd(server.execute("queue.primary_queue"))
    l = string.split(separator=" ", l)
    if list.length(l) > 0 then
      source.skip(s)
      "Skipped"
    else
      "Not skipped"
    end
  end
 # Register the command:
 server.register(namespace="source",
                 usage="skip",
                 description="Skip the current song.",
                 "skip",fun(s) -> begin log("source.skip") skip(s) end)
end

dyn_out = output.icecast(%wav,
                     host="localhost",
                     port=8999,
                     password=stream_harbor_pass,
                     mount="test-harbor",
                     fallible=true)

def set_dynamic_source_id(id) =
    current_dyn_id := id 
    string_of(!current_dyn_id)
end

def get_dynamic_source_id() =
    string_of(!current_dyn_id)
end


# Function to create a playlist source and output it.
def create_dynamic_source(uri) =
    # The playlist source 
    s = audio_to_stereo(input.http(buffer=2., max=12., uri))

    # The output
    active_dyn_out = dyn_out(s)

    # We register both source and output 
    # in the list of sources
    dyn_sources := 
      list.append([(!current_dyn_id, s),(!current_dyn_id, active_dyn_out)], !dyn_sources)

    notify([("schedule_table_id", !current_dyn_id)])
    "Done!"
end


# A function to destroy a dynamic source
def destroy_dynamic_source(id) = 
  # We need to find the source in the list,
  # remove it and destroy it. Currently, the language
  # lacks some nice operators for that so we do it
  # the functional way

  # This function is executed on every item in the list
  # of dynamic sources
  def parse_list(ret, current_element) = 
    # ret is of the form: (matching_sources, remaining_sources)
    # We extract those two:
    matching_sources = fst(ret)
    remaining_sources = snd(ret)

    # current_element is of the form: ("uri", source) so 
    # we check the first element
    current_id = fst(current_element)
    if current_id == id then
      # In this case, we add the source to the list of
      # matched sources
      (list.append( [snd(current_element)], 
                     matching_sources),
       remaining_sources)
    else
       # In this case, we put the element in the list of remaining
       # sources
      (matching_sources,
       list.append([current_element], 
                    remaining_sources))
    end
  end
    
  # Now we execute the function:
  result = list.fold(parse_list, ([], []), !dyn_sources)
  matching_sources = fst(result)
  remaining_sources = snd(result)

  # We store the remaining sources in dyn_sources
  dyn_sources := remaining_sources

  # If no source matched, we return an error
  if list.length(matching_sources) == 0 then
    "Error: no matching sources!"
  else
    # We stop all sources
    list.iter(source.shutdown, matching_sources)
    # And return
    "Done!"
  end
end




# A function to destroy a dynamic source
def destroy_dynamic_source_all() = 
  # We need to find the source in the list,
  # remove it and destroy it. Currently, the language
  # lacks some nice operators for that so we do it
  # the functional way

  # This function is executed on every item in the list
  # of dynamic sources
  def parse_list(ret, current_element) = 
    # ret is of the form: (matching_sources, remaining_sources)
    # We extract those two:
    matching_sources = fst(ret)
    remaining_sources = snd(ret)

    # current_element is of the form: ("uri", source) so 
    # we check the first element
    current_uri = fst(current_element)
    # in this case, we add the source to the list of
    # matched sources
    (list.append( [snd(current_element)], 
                    matching_sources),
    remaining_sources)
  end
    
  # now we execute the function:
  result = list.fold(parse_list, ([], []), !dyn_sources)
  matching_sources = fst(result)
  remaining_sources = snd(result)

  # we store the remaining sources in dyn_sources
  dyn_sources := remaining_sources

  # if no source matched, we return an error
  if list.length(matching_sources) == 0 then
    "error: no matching sources!"
  else
    # we stop all sources
    list.iter(source.shutdown, matching_sources)
    # And return
    "Done!"
  end
end



