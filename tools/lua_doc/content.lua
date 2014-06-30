real_darktable = require "darktable"
require "darktable.debug"
local tmp_node

---------------------
-- check for generator functions
---------------------
for _,v in pairs({"node_to_string","para","startlist","listel","endlist","code","emphasis"})   do
	if _ENV[v]== nil then
		error("function '"..v.."' not defined when requiring content")
	end
end
---------------------
-- check for database content
---------------------
if  #real_darktable.database == 0 then
	error("The database needs to contain at least one image to generate documentation")
end
if  #real_darktable.styles == 0 then
	error("The database needs to contain at least one style to generate documentation")
end


doc = require "core"
darktable = doc.toplevel.darktable
types = doc.toplevel.types
events = doc.toplevel.events
attributes = doc.toplevel.attributes


local function my_tostring(obj)
  if not obj then 
  error("incorrect object")
  end
  return tostring(obj)
end

local function remove_all_children(node)
	for k, v in node:all_children() do
		v:remove_parent(node)
		node[k] = nil
	end
end
-- prevent some objects to appear at the wrong end of the tree
remove_all_children(types.dt_lib_module_t.views)
print("warning, avoid problems with picasa/facebook")
types.dt_imageio_module_storage_data_email:set_text([[TBSL undocumented, force first]])

----------------------
--  TOPLEVEL        --
----------------------
doc.toplevel:set_text([[To access the darktable specific functions you must load the darktable environement:]]..
code([[darktable = require "darktable"]])..
[[All functions and data are accessed through the darktable module.]]..para()..
[[This documentation for API version ]]..real_darktable.configuration.api_version_string..[[.]])
----------------------
--  DARKTABLE       --
----------------------
darktable:set_text([[The darktable library is the main entry point for all access to the darktable internals.]])
darktable.print:set_text([[Will print a string to the darktable control log (the long overlayed window that appears over the main panel).]])
darktable.print:add_parameter("message","string",[[The string to display which should be a single line.]])

darktable.print_error:set_text([[This function will print its parameter if the Lua logdomain is activated. Start darktable with the "-d lua" command line option to enable the Lua logdomain.]])
darktable.print_error:add_parameter("message","string",[[The string to display.]])

darktable.register_event:set_text([[This function registers a callback to be called when a given event happens.]]..para()..
[[Events are documented ]]..node_to_string(events,[[in the event section.]]))
darktable.register_event:add_parameter("event_type","string",[[The name of the event to register to.]])
darktable.register_event:add_parameter("callback","function",[[The function to call on event. The signature of the function depends on the type of event.]])
darktable.register_event:add_parameter("...","variable",[[Some events need extra parameters at registration time; these must be specified here.]])

darktable.register_storage:set_text([[This function will add a new storage implemented in Lua.]]..para()..
[[A storage is a module that is responsible for handling images once they have been generated during export. Examples of core storages include filesystem, e-mail, facebook...]])
darktable.register_storage:add_parameter("plugin_name","string",[[A Unique name for the plugin.]])
darktable.register_storage:add_parameter("name","string",[[A human readable name for the plugin.]])
tmp_node = darktable.register_storage:add_parameter("store","function",[[This function is called once for each exported image. Images can be exported in parallel but the calls to this function will be serialized.]])
tmp_node:set_attribute("optional",true)
tmp_node:add_parameter("storage",my_tostring(types.dt_imageio_module_storage_t),[[The storage object used for the export.]])
tmp_node:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The exported image object.]])
tmp_node:add_parameter("format",my_tostring(types.dt_imageio_module_format_t),[[The format object used for the export.]])
tmp_node:add_parameter("filename","string",[[The name of a temporary file where the processed image is stored.]])
tmp_node:add_parameter("number","integer",[[The number of the image out of the export series.]])
tmp_node:add_parameter("total","integer",[[The total number of images in the export series.]])
tmp_node:add_parameter("high_quality","boolean",[[True if the export is high quality.]])
tmp_node:add_parameter("extra_data","table",[[An empty Lua table to take extra data. This table is common to the initialize, store and finalize calls in an export serie.]])
tmp_node = darktable.register_storage:add_parameter("finalize","function",[[This function is called once all images are processed and all store calls are finished.]])
tmp_node:set_attribute("optional",true)
tmp_node:add_parameter("storage",my_tostring(types.dt_imageio_module_storage_t),[[The storage object used for the export.]])
tmp_node:add_parameter("image_table","table",[[A table keyed by the exported image objects and valued with the corresponding temporary export filename.]])
tmp_node:add_parameter("extra_data","table",[[An empty Lua table to store extra data. This table is common to all calls to store and the call to finalize in a given export series.]])
tmp_node = darktable.register_storage:add_parameter("supported","function",[[A function called to check if a given image format is supported by the Lua storage; this is used to build the dropdown format list for the GUI.]]..para()..
[[Note that the parameters in the format are the ones currently set in the GUI; the user might change them before export.]])
tmp_node:set_attribute("optional",true)
tmp_node:add_parameter("storage",my_tostring(types.dt_imageio_module_storage_t),[[The storage object tested.]])
tmp_node:add_parameter("format",my_tostring(types.dt_imageio_module_format_t),[[The format object to report about.]])
tmp_node:add_return("boolean",[[True if the corresponding format is supported.]])
tmp_node = darktable.register_storage:add_parameter("initialize","function",[[A function called before storage happens]]..para().. 
[[This function can change the list of exported functions]])
tmp_node:set_attribute("optional",true)
tmp_node:add_parameter("storage",my_tostring(types.dt_imageio_module_storage_t),[[The storage object tested.]])
tmp_node:add_parameter("format",my_tostring(types.dt_imageio_module_format_t),[[The format object to report about.]])
tmp_node:add_parameter("images","table of "..my_tostring(types.dt_lua_image_t),[[A table containing images to be exported.]])
tmp_node:add_parameter("high_quality","boolean",[[True if the export is high quality.]])
tmp_node:add_parameter("extra_data","table",[[An empty Lua table to take extra data. This table is common to the initialize, store and finalize calls in an export serie.]])
tmp_node:add_return("table or nil",[[The modified table of images to export or nil]]..para()..
[[If nil (or nothing) is returned, the original list of images will be exported]]..para()..
[[If a table of images is returned, that table will be used instead. The table can be empty. The images parameter can be modified and returned]])
tmp_node:add_version_info([[This parameter was added]])


darktable.films:set_text([[A table containing all the film objects in the database.]])
darktable.films['#']:set_text([[Each film has a numeric entry in the database.]])
darktable.films.new:set_text([[Creates a new empty film]]..para()..
[[ see ]]..my_tostring(darktable.database.import)..[[ to import a directory with all its images and to add images to a film]])
darktable.films.new:add_parameter("directory","string",[[The directory that the new film will represent. The directory must exist]])
darktable.films.new:add_return(my_tostring(types.dt_lua_film_t),"The newly created film, or the existing film if the directory is already imported")
darktable.films.new:add_version_info([[The function was added]])

----------------------
--  DARKTABLE.GUI   --
----------------------
darktable.gui:set_text([[This subtable contains function and data to manipulate the darktable user interface with Lua.]]..para()..
[[Most of these function won't do anything if the GUI is not enabled (i.e you are using the command line version darktabl-cli instead of darktable).]])

darktable.gui.action_images:set_text([[A table of ]]..my_tostring(types.dt_lua_image_t)..[[ on which the user expects UI actions to happen.]]..para()..
[[It is based on both the hovered image and the selection and is consistent with the way darktable works.]]..para()..
[[It is recommended to use this table to implement Lua actions rather than dt.gui.hovered or dt.gui.selected to be consistant with darktable's GUI.]])

remove_all_children(darktable.gui.action_images)

darktable.gui.hovered:set_text([[The image under the cursor or nil if no image is hovered.]])
darktable.gui.selection:set_text([[Allows to change the set of selected images.]])
darktable.gui.selection:add_parameter("selection","table of "..my_tostring(types.dt_lua_image_t),[[A table of images which will define the selected images. If this parameter is not given the selection will be untouched. If an empty table is given the selection will be emptied.]]):set_attribute("optional",true)
darktable.gui.selection:add_return("table of "..my_tostring(types.dt_lua_image_t),[[A table containing the selection as it was before the function was called.]])
darktable.gui.selection:set_attribute("implicit_yield",true)
darktable.gui.current_view:set_text([[Allows to change the current view.]])
darktable.gui.current_view:add_parameter("view",my_tostring(types.dt_view_t),[[The view to switch to. If empty the current view is unchanged]]):set_attribute("optional",true)
darktable.gui.current_view:add_return(my_tostring(types.dt_view_t),[[the current view]])
darktable.gui.current_view:add_version_info([[Function added]])

----------------------
--  DARKTABLE.TAGS  --
----------------------
darktable.tags:set_text([[Allows access to all existing tags.]])

darktable.tags["#"]:set_text([[Each existing tag has a numeric entry in the tags table - use ipairs to iterate over them.]])
darktable.tags.create:set_text([[Creates a new tag and return it. If the tag exists return the existing tag.]])
darktable.tags.create:add_parameter("name","string",[[The name of the new tag.]])
darktable.tags.find:set_text([[Returns the tag object or nil if the tag doesn't exist.]])
darktable.tags.find:add_parameter("name","string",[[The name of the tag to find.]])
darktable.tags.find:add_return(my_tostring(types.dt_lua_tag_t),[[The tag object or nil.]])
darktable.tags.delete:set_text([[Deletes the tag object, detaching it from all images.]])
darktable.tags.delete:add_parameter("tag",my_tostring(types.dt_lua_tag_t),[[The tag to be deleted.]])
darktable.tags.delete:set_main_parent(darktable.tags)
darktable.tags.attach:set_text([[Attach a tag to an image; the order of the parameters can be reversed.]])
darktable.tags.attach:add_parameter("tag",my_tostring(types.dt_lua_tag_t),[[The tag to be attached.]])
darktable.tags.attach:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image to attach the tag to.]])
darktable.tags.attach:set_main_parent(darktable.tags)
darktable.tags.detach:set_text([[Detach a tag from an image; the order of the parameters can be reversed.]])
darktable.tags.detach:add_parameter("tag",my_tostring(types.dt_lua_tag_t),[[The tag to be detached.]])
darktable.tags.detach:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image to detach the tag from.]])
darktable.tags.detach:set_main_parent(darktable.tags)
darktable.tags.get_tags:set_text([[Gets all tags attached to an image.]])
darktable.tags.get_tags:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image to get the tags from.]])
darktable.tags.get_tags:add_return("table of "..my_tostring(types.dt_lua_tag_t),[[A table of tags that are attached to the image.]])
darktable.tags.get_tags:set_main_parent(darktable.tags)

------------------------------
--  DARKTABLE.CONFIGURATION --
------------------------------
darktable.configuration:set_text([[This table regroups values that describe details of the configuration of darktable.]])
darktable.configuration.version:set_text([[The version number of darktable.]])
darktable.configuration.has_gui:set_text([[True if darktable has a GUI (launched through the main darktable command, not darktable-cli).]])
darktable.configuration.verbose:set_text([[True if the Lua logdomain is enabled.]])
darktable.configuration.tmp_dir:set_text([[The name of the directory where darktable will store temporary files.]])
darktable.configuration.config_dir:set_text([[The name of the directory where darktable will find its global configuration objects (modules).]])
darktable.configuration.cache_dir:set_text([[The name of the directory where darktable will store its mipmaps.]])
darktable.configuration.api_version_major:set_text([[The major version number of the lua API.]])
darktable.configuration.api_version_major:add_version_info([[field added]])
darktable.configuration.api_version_minor:set_text([[The minor version number of the lua API.]])
darktable.configuration.api_version_minor:add_version_info([[field added]])
darktable.configuration.api_version_patch:set_text([[The patch version number of the lua API.]])
darktable.configuration.api_version_patch:add_version_info([[field added]])
darktable.configuration.api_version_suffix:set_text([[The version suffix of the lua API.]])
darktable.configuration.api_version_suffix:add_version_info([[field added]])
darktable.configuration.api_version_string:set_text([[The version description of the lua API. This is a string compatible with the semantic versionning convention]])
darktable.configuration.api_version_string:add_version_info([[field added]])

-----------------------------
--  DARKTABLE.PREFERENCES  --
-----------------------------
darktable.preferences:set_text([[Lua allows you do manipulate preferences. Lua has its own namespace for preferences and you can't access nor write normal darktable preferences.]]..para()..
[[Preference handling functions take a _script_ parameter. This is a string used to avoid name collision in preferences (i.e namespace). Set it to something unique, usually the name of the script handling the preference.]]..para()..
[[Preference handling functions can't guess the type of a parameter. You must pass the type of the preference you are handling. Allowed values are the following strings

* string
* bool
* integer
* float]])
darktable.preferences:add_version_info("added float parameters")

darktable.preferences.register:set_text([[Creates a new preference entry in the Lua tab of the preference screen. If this function is not called the preference can't be set by the user (you can still read and write invisible preferences).]])
darktable.preferences.register:add_parameter("script","string",[[Invisible prefix to guarantee unicity of preferences.]])
darktable.preferences.register:add_parameter("name","string",[[A unique name used with the script part to identify the preference.]])
darktable.preferences.register:add_parameter("type","string",[[The type of the preference - one of the string values described above.]])
darktable.preferences.register:add_parameter("label","string",[[The label displayed in the preference screen.]])
darktable.preferences.register:add_parameter("tooltip","string",[[The tooltip to display in the preference menue.]])
darktable.preferences.register:add_parameter("default","depends on type",[[Default value to use when not set explicitely or by the user.]]):set_attribute("optional",true)
darktable.preferences.register:add_parameter("min","int or float",[[Minimum value (integer and float preferences only).]]):set_attribute("optional",true)
darktable.preferences.register:add_parameter("max","int or float",[[Maximum value (integer and float preferences only).]]):set_attribute("optional",true)
darktable.preferences.register:add_parameter("step","float",[[Step of the spinner (float preferences only).]]):set_attribute("optional",true)
    
darktable.preferences.read:set_text([[Reads a value from a Lua preference.]])
darktable.preferences.read:add_parameter("script","string",[[Invisible prefix to guarantee unicity of preferences.]])
darktable.preferences.read:add_parameter("name","string",[[The name of the preference displayed in the preference screen.]])
darktable.preferences.read:add_parameter("type","string",[[The type of the preference - one of the string values described above.]])
darktable.preferences.read:add_return("depends on type",[[The value of the preference.]])
    
darktable.preferences.write:set_text([[Writes a value to a Lua preference.]])
darktable.preferences.write:add_parameter("script","string",[[Invisible prefix to guarantee unicity of preferences.]])
darktable.preferences.write:add_parameter("name","string",[[The name of the preference displayed in the preference screen.]])
darktable.preferences.write:add_parameter("type","string",[[The type of the preference - one of the string values described above.]])
darktable.preferences.write:add_parameter("value","depends on type",[[The value to set the preference to.]])


-----------------------
--  DARKTABLE.STYLES --
-----------------------

darktable.styles:set_text([[This pseudo table allows you to access and manipulate styles.]])

darktable.styles["#"]:set_text([[Each existing style has a numeric index; you can iterate them using ipairs.]])

darktable.styles.create:set_text([[Create a new style based on an image.]])
darktable.styles.create:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image to create the style from.]])
darktable.styles.create:add_parameter("name","string",[[The name to give to the new style.]])
darktable.styles.create:add_parameter("description","string",[[The description of the new style.]]):set_attribute("optional")
darktable.styles.create:add_return(my_tostring(types.dt_style_t),[[The new style object.]])
darktable.styles.create:set_main_parent(darktable.styles)

darktable.styles.delete:set_text([[Deletes an existing style.]])
darktable.styles.delete:add_parameter("style",my_tostring(types.dt_style_t),[[the style to delete]])
darktable.styles.delete:set_main_parent(darktable.styles)

darktable.styles.duplicate:set_text([[Create a new style based on an existing style.]])
darktable.styles.duplicate:add_parameter("style",my_tostring(types.dt_style_t),[[The style to base the new style on.]])
darktable.styles.duplicate:add_parameter("name","string",[[The new style's name.]])
darktable.styles.duplicate:add_parameter("description","string",[[The new style's description.]]):set_attribute("optional")
darktable.styles.duplicate:add_return(my_tostring(types.dt_style_t),[[The new style object.]])
darktable.styles.duplicate:set_main_parent(darktable.styles)

darktable.styles.apply:set_text([[Apply a style to an image. The order of parameters can be inverted.]])
darktable.styles.apply:add_parameter("style",my_tostring(types.dt_style_t),[[The style to use.]])
darktable.styles.apply:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image to apply the style to.]])
darktable.styles.apply:set_main_parent(darktable.styles)

darktable.styles.import:set_text([[Import a style from an external .dtstyle file]]):add_version_info("function_added")
darktable.styles.import:add_parameter("filename","string","The file to import");
darktable.styles.import:set_main_parent(darktable.styles)

darktable.styles.export:set_text([[Export a style to an external .dtstyle file]]):add_version_info("function_added")
darktable.styles.export:add_parameter("style",my_tostring(types.dt_style_t),"The file to import");
darktable.styles.export:add_parameter("directory","string","The directory to export to");
darktable.styles.export:add_parameter("overwrite","boolean","Is overwriting an existing file allowed"):set_attribute("optional")
darktable.styles.export:set_main_parent(darktable.styles)
-------------------------
--  DARKTABLE.DATABASE --
-------------------------

darktable.database:set_text([[Allows to access the database of images. Note that duplicate images (images with the same RAW but different XMP) will appear multiple times with different duplicate indexes. Also note that all images are here. This table is not influenced by any GUI filtering (collections, stars etc...).]])


darktable.database["#"]:set_text([[Each image in the database appears with a numerical index; you can interate them using ipairs.]])
darktable.database.duplicate:set_text([[Creates a duplicate of an image and returns it.]])
darktable.database.duplicate:add_parameter("image",my_tostring(types.dt_lua_image_t),[[the image to duplicate]])
darktable.database.duplicate:add_return(my_tostring(types.dt_lua_image_t),[[The new image object.]])
darktable.database.duplicate:set_main_parent(darktable.database)

darktable.database.import:set_text([[Imports new images into the database.]])
darktable.database.import:add_parameter("location","string",[[The filename or directory to import images from.

NOTE: If the images are set to be imported recursively in preferences only the toplevel film is returned (the one whose path was given as a parameter).

NOTE2: If the parameter is a directory the call is non-blocking; the film object will not have the newly imported images yet. Use a post-import-film filtering on that film to react when images are actually imported.


]])
darktable.database.duplicate:add_return(my_tostring(types.dt_lua_image_t),[[The created image if an image is imported or the toplevel film object if a film was imported.]])
darktable.database.move_image:set_text([[Physically moves an image (and all its duplicates) to another film.]]..para()..
[[This will move the image file, the related XMP and all XMP for the duplicates to the directory of the new film]]..para()..
[[Note that the parameter order is not relevant.]])
darktable.database.move_image:add_version_info("function added")
darktable.database.move_image:add_parameter("image",tostring(types.dt_lua_image_t),[[The image to move]])
darktable.database.move_image:add_parameter("film",tostring(types.dt_lua_film_t),[[The film to move to]])
darktable.database.move_image:set_main_parent(darktable.database)
darktable.database.copy_image:set_text([[Physically copies an image to another film.]]..para()..
[[This will copy the image file and the related XMP to the directory of the new film]]..para()..
[[If there is already a file with the same name as the image file, it wil create a duplicate from that file instead]]..para()..
[[Note that the parameter order is not relevant.]])
darktable.database.copy_image:add_version_info("function added")
darktable.database.copy_image:add_parameter("image",tostring(types.dt_lua_image_t),[[The image to copy]])
darktable.database.copy_image:add_parameter("film",tostring(types.dt_lua_film_t),[[The film to copy to]])
darktable.database.copy_image:add_return(tostring(types.dt_lua_image_t),[[The new image]])
darktable.database.copy_image:set_main_parent(darktable.database)

------------------------
--  DARKTABLE.MODULES --
------------------------

darktable.modules:set_text([[This table describe the different loadable modules of darktable.]])

darktable.modules.format:set_text([[Functions to get parameter objects for the different export formats.]])

darktable.modules.format.png:set_text([[Used to get a new png format object.]])
darktable.modules.format.png:add_return(my_tostring(types.dt_imageio_module_format_data_png),[[A new format object describing the parameters to export to png - initialised to the values contained in the GUI.]])

darktable.modules.format.png:set_alias(darktable.modules.format.tiff)
darktable.modules.format.png:set_alias(darktable.modules.format.exr)
darktable.modules.format.png:set_alias(darktable.modules.format.copy)
darktable.modules.format.png:set_alias(darktable.modules.format.pfm)
darktable.modules.format.png:set_alias(darktable.modules.format.jpeg)
darktable.modules.format.png:set_alias(darktable.modules.format.ppm)
darktable.modules.format.png:set_alias(darktable.modules.format.webp)
darktable.modules.format.png:set_alias(darktable.modules.format.j2k)

darktable.modules.storage:set_text([[Functions to get parameter objects for the different export storages.

New values may appear in this table if new storages are registered using Lua.]])
darktable.modules.storage.email:set_text([[Used to get a new email storage object.]])
darktable.modules.storage.email:add_return(my_tostring(types.dt_imageio_module_storage_t),[[A new storage object describing the parameters to export with - initialised to the values contained in the GUI.]])
darktable.modules.storage.email:set_alias(darktable.modules.storage.latex)
darktable.modules.storage.email:set_alias(darktable.modules.storage.disk)
darktable.modules.storage.email:set_alias(darktable.modules.storage.gallery)
darktable.modules.storage.email:set_alias(darktable.modules.storage.flickr)
darktable.modules.storage.email:set_alias(darktable.modules.storage.facebook)
darktable.modules.storage.email:set_alias(darktable.modules.storage.picasa)

for k, v in darktable.modules.view:unskiped_children() do
	v:set_main_parent(darktable.modules.view)
end
darktable.modules.view:set_text([[The different views in darktable]])
darktable.modules.view:add_version_info([[View objects added]])
darktable.modules.view.map:set_text([[The map view]])
darktable.modules.view.map.latitude:set_text([[The latitude of the center of the map]])
darktable.modules.view.map.longitude:set_text([[The longitude of the center of the map]])
darktable.modules.view.map.zoom:set_text([[The current zoom level of the map]])

darktable.modules.view.darkroom:set_text([[The darkroom view]])
darktable.modules.view.lighttable:set_text([[The lighttable view]])
darktable.modules.view.tethering:set_text([[The tethering view]])
darktable.modules.view.slideshow:set_text([[The slideshow view]])

for k, v in darktable.modules.lib:unskiped_children() do
	local real_node = real_darktable.modules.lib[k]
	v:set_attribute("position",real_node.position);
	v:set_attribute("container",real_node.container);
	local matching_views={}
	for k2,v2 in pairs(real_node.views) do
		table.insert(matching_views,darktable.modules.view[v2.id])
	end
	v:set_attribute("views",matching_views);
end
darktable.modules.lib:set_text([[This table allows to reference all lib objects]]..para()..
[[lib are the graphical blocks within each view.]]..para()..
[[To quickly figure out what lib is what, you can use the following code which will make a given lib blink.]]..para()..
code([[local tested_module="global_toolbox"
dt.modules.lib[tested_module].visible=false
coroutine.yield("wait_ms",2000)
while true do
  dt.modules.lib[tested_module].visible = not dt.modules.lib[tested_module].visible
  coroutine.yield("wait_ms",2000)
end]]))
darktable.modules.lib:add_version_info([[lib were added]])

darktable.modules.lib.backgroundjobs:set_text([[The window displaying the currently running jobs]])
darktable.modules.lib.backgroundjobs.create_job:set_text([[The window displaying the currently running jobs]])
darktable.modules.lib.backgroundjobs.create_job:add_parameter("text","string",[[The text to display in the job entry]])
darktable.modules.lib.backgroundjobs.create_job:add_parameter("percentage","boolean",[[Should a progress bar be displayed]]):set_attribute("optional",true)
tmp = darktable.modules.lib.backgroundjobs.create_job:add_parameter("cancel_callback","function",[[A function called when the cancel button for that job is pressed]]..para().."note that the job won't be destroyed automatically. You need to set "..my_tostring(types.dt_lua_backgroundjob_t.valid).." to false for that")
tmp:set_attribute("optional",true)
tmp:add_parameter("job",my_tostring(types.dt_lua_backgroundjob_t),[[The job who is being cancelded]])
darktable.modules.lib.backgroundjobs.create_job:add_return(my_tostring(types.dt_lua_backgroundjob_t),[[The newly created job object]])

darktable.modules.lib.snapshots:set_text([[The UI element that manipulates snapshots in darkroom]])
darktable.modules.lib.snapshots.ratio:set_text([[The place in the screen where the line separating the snapshot is. Between 0 and 1]])
darktable.modules.lib.snapshots.direction:set_text([[The direction of the snapshot overlay, can be one of:]]..startlist()..
listel("top")..
listel("bottom")..
listel("left")..
listel("right")..
endlist())

darktable.modules.lib.snapshots["#"]:set_text([[The different snapshots for the image]])
darktable.modules.lib.snapshots.selected:set_text([[The currently selected snapshot]])
darktable.modules.lib.snapshots.take_snapshot:set_text([[Take a snapshot of the current image and add it to the UI]]..para()..[[The snapshot file will be generated at the next redraw of the main window]])
darktable.modules.lib.snapshots.max_snapshot:set_text([[The maximum number of snapshots]])

darktable.modules.lib.styles:set_text([[The style selection menu]])
darktable.modules.lib.metadata_view:set_text([[The widget displaying metadata about the current image]])
darktable.modules.lib.metadata:set_text([[The widget allowing modification of metadata fields on the current image]])
darktable.modules.lib.hinter:set_text([[The small line of text at the top of the UI showing the number of selected images]])
darktable.modules.lib.modulelist:set_text([[The window allowing to set modules as visible/hidden/favorite]])
darktable.modules.lib.filmstrip:set_text([[The filmstrip at the bottom of some views]])
darktable.modules.lib.viewswitcher:set_text([[The labels allowing to switch view]])
darktable.modules.lib.darktable_label:set_text([[The darktable logo in the upper left corner]])
darktable.modules.lib.tagging:set_text([[The tag manipulation UI]])
darktable.modules.lib.geotagging:set_text([[The geotagging time synchronisation UI]])
darktable.modules.lib.recentcollect:set_text([[The recent collection UI element]])
darktable.modules.lib.global_toolbox:set_text([[The common tools to all view (settings, grouping...)]])
darktable.modules.lib.filter:set_text([[The image-filter menus at the top of the UI]])
darktable.modules.lib.import:set_text([[The buttons to start importing images]])
darktable.modules.lib.ratings:set_text([[The starts to set the rating of an image]])
darktable.modules.lib.select:set_text([[The buttons that allow to quickly change the selection]])
darktable.modules.lib.collect:set_text([[The collection UI element that allows to filter images by collection]])
darktable.modules.lib.colorlabels:set_text([[The color buttons that allow to set labels on an image]])
darktable.modules.lib.lighttable_mode:set_text([[The navigation and zoom level UI in lighttable]])
darktable.modules.lib.copy_history:set_text([[The UI element that manipulates history]])
darktable.modules.lib.image:set_text([[The UI element that manipulates the current image]])
darktable.modules.lib.modulegroups:set_text([[The icons describing the different iop groups]])
darktable.modules.lib.module_toolbox:set_text([[The tools on the bottom line of the UI (overexposure)]])
darktable.modules.lib.session:set_text([[The session UI when tethering]])
darktable.modules.lib.histogram:set_text([[The histogram widget]])
darktable.modules.lib.export:set_text([[The export menu]])
darktable.modules.lib.history:set_text([[The history manipulation menu]])
darktable.modules.lib.colorpicker:set_text([[The colorpicker menu]])
darktable.modules.lib.navigation:set_text([[The full image preview to allow navigation]])
darktable.modules.lib.masks:set_text([[The masks window]])
darktable.modules.lib.view_toolbox:set_text([[]])
darktable.modules.lib.live_view:set_text([[The liveview window]])
darktable.modules.lib.map_settings:set_text([[The map setting window]])
darktable.modules.lib.camera:set_text([[The camera selection UI]])
darktable.modules.lib.location:set_text([[The location ui]])

----------------------
--  DARKTABLE.DEBUG --
----------------------
darktable.debug:set_text([[This section must be activated separately by calling 

require "darktable.debug"
]])

darktable.debug.dump:set_text([[This will return a string describing everything Lua knows about an object, used to know what an object is.

This function is recursion-safe and can be used to dump _G if needed.]])
darktable.debug.dump:add_parameter("object","anything",[[The object to dump.]])
darktable.debug.dump:add_parameter("name","string",[[A name to use for the object.]]):set_attribute("optional",true)
tmp_node = darktable.debug.dump:add_parameter("known","table",[[A table of object,string pairs. Any object in that table will not be dumped, the string will be printed instead.]]..para().."defaults to "..my_tostring(darktable.debug.known).." if not set")
tmp_node:set_attribute("optional",true)
darktable.debug.dump:add_return("string",[[A string containing a text description of the object - can be very long.]])

darktable.debug.debug:set_text([[Initialized to false; set it to true to also dump information about metatables.]])
darktable.debug.max_depth:set_text([[Initialized to 10; The maximum depth to recursively dump content.]])

remove_all_children(darktable.debug.known) -- debug values, not interesting
darktable.debug.known:set_text([[A table containing the default value of ]]..my_tostring(tmp_node))
darktable.debug.type:set_text([[Similar to the system function type() but it will return the real type instead of "userdata" for darktable specific objects.]])
darktable.debug.type:add_parameter("object","anything",[[The object whos type must be reported.]])
darktable.debug.type:add_return("string",[[A string describing the type of the object.]])
	
----------------------
--  TYPES           --
----------------------
types:set_text([[This section documents types that are specific to darktable's Lua API.]])


types.dt_lua_image_t:set_text([[Image objects represent an image in the database. This is slightly different from a file on disk since a file can have multiple developements.

Note that this is the real image object; changing the value of a field will immediately change it in darktable and will be reflected on any copy of that image object you may have kept.]])


types.dt_lua_image_t.id:set_text([[A unique id identifying the image in the database.]])
types.dt_lua_image_t.path:set_text([[The file the directory containing the image.]])
types.dt_lua_image_t.film:set_text([[The film object that contains this image.]])
types.dt_lua_image_t.filename:set_text([[The filename of the image.]])
types.dt_lua_image_t.duplicate_index:set_text([[If there are multiple images based on a same file, each will have a unique number, starting from 0.]])


types.dt_lua_image_t.publisher:set_text([[The publisher field of the image.]])
types.dt_lua_image_t.title:set_text([[The title field of the image.]])
types.dt_lua_image_t.creator:set_text([[The creator field of the image.]])
types.dt_lua_image_t.rights:set_text([[The rights field of the image.]])
types.dt_lua_image_t.description:set_text([[The description field for the image.]])

types.dt_lua_image_t.exif_maker:set_text([[The maker exif data.]])
types.dt_lua_image_t.exif_model:set_text([[The camera model used.]])
types.dt_lua_image_t.exif_lens:set_text([[The id string of the lens used.]])
types.dt_lua_image_t.exif_aperture:set_text([[The aperture saved in the exif data.]])
types.dt_lua_image_t.exif_exposure:set_text([[The exposure time of the image.]])
types.dt_lua_image_t.exif_focal_length:set_text([[The focal length of the image.]])
types.dt_lua_image_t.exif_iso:set_text([[The iso used on the image.]])
types.dt_lua_image_t.exif_datetime_taken:set_text([[The date and time of the image.]])
types.dt_lua_image_t.exif_focus_distance:set_text([[The distance of the subject.]])
types.dt_lua_image_t.exif_crop:set_text([[The exif crop data.]])
types.dt_lua_image_t.latitude:set_text([[GPS latitude data of the image, nil if not set.]]):add_version_info("the field is now nil instead of NAN if not set")
types.dt_lua_image_t.longitude:set_text([[GPS longitude data of the image, nil if not set.]]):add_version_info("the field is now nil instead of NAN if not set")
types.dt_lua_image_t.is_raw:set_text([[True if the image is a RAW file.]])
types.dt_lua_image_t.is_ldr:set_text([[True if the image is a ldr image.]])
types.dt_lua_image_t.is_hdr:set_text([[True if the image is a hdr image.]])
types.dt_lua_image_t.width:set_text([[The width of the image.]])
types.dt_lua_image_t.height:set_text([[The height of the image.]])
types.dt_lua_image_t.rating:set_text([[The rating of the image (-1 for rejected).]])
types.dt_lua_image_t.red:set_text([[True if the image has the corresponding colorlabel.]])
types.dt_lua_image_t.red:set_alias(types.dt_lua_image_t.blue)
types.dt_lua_image_t.red:set_alias(types.dt_lua_image_t.green)
types.dt_lua_image_t.red:set_alias(types.dt_lua_image_t.yellow)
types.dt_lua_image_t.red:set_alias(types.dt_lua_image_t.purple)
types.dt_lua_image_t.reset:set_text([[Removes all processing from the image, reseting it back to its original state]])
types.dt_lua_image_t.reset:add_version_info("field added")
types.dt_lua_image_t.reset:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image whose history will be deleted]])
types.dt_lua_image_t.delete:set_text([[Removes an image from the database]])
types.dt_lua_image_t.delete:add_version_info("field added")
types.dt_lua_image_t.delete:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image to remove]])

types.dt_lua_image_t.group_with:set_text([[Puts the first image in the same group as the second image. If no second image is provided the image will be in its own group.]])
types.dt_lua_image_t.group_with:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image whose group must be changed.]])
types.dt_lua_image_t.group_with:add_parameter("image2",my_tostring(types.dt_lua_image_t),[[The image we want to group with.]]):set_attribute("optional",true)
types.dt_lua_image_t.make_group_leader:set_text([[Makes the image the leader of its group.]])
types.dt_lua_image_t.make_group_leader:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image we want as the leader.]])
types.dt_lua_image_t.get_group_members:set_text([[Returns a table containing all ]]..my_tostring(types.dt_lua_image_t)..[[ of the group. The group leader is both at a numeric key and at the "leader" special key (so you probably want to use ipairs to iterate through that table).]])
types.dt_lua_image_t.get_group_members:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image whose group we are querying.]])
types.dt_lua_image_t.get_group_members:add_return("table of "..my_tostring(types.dt_lua_image_t),[[A table of image objects containing all images that are in the same group as the image.]])
darktable.tags.attach:set_alias(types.dt_lua_image_t.attach_tag)
types.dt_lua_image_t.group_leader:set_text([[The image which is the leader of the group this image is a member of.]])
types.dt_lua_image_t.local_copy:set_text([[True if the image has a copy in the local cache]])
types.dt_lua_image_t.local_copy:add_version_info([[field added]])

types.dt_imageio_module_format_t:set_text([[A virtual type representing all format types.]])
types.dt_imageio_module_format_t.plugin_name:set_text([[A unique name for the plugin.]])
types.dt_imageio_module_format_t.name:set_text([[A human readable name for the plugin.]])
types.dt_imageio_module_format_t.extension:set_text([[The typical filename extension for that format.]])
types.dt_imageio_module_format_t.mime:set_text([[The mime type associated with the format.]])
types.dt_imageio_module_format_t.max_width:set_text([[The max width allowed for the format (0 = unlimited).]])
types.dt_imageio_module_format_t.max_height:set_text([[The max height allowed for the format (0 = unlimited).]])
types.dt_imageio_module_format_t.write_image:set_text([[Exports an image to a file. This is a blocking operation that will not return until the image is exported.]])
types.dt_imageio_module_format_t.write_image:set_attribute("implicit_yield",true)
types.dt_imageio_module_format_t.write_image:add_parameter("format",my_tostring(types.dt_imageio_module_format_t),[[The format that will be used to export.]])
types.dt_imageio_module_format_t.write_image:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image object to export.]])
types.dt_imageio_module_format_t.write_image:add_parameter("filename","string",[[The filename to export to.]])
types.dt_imageio_module_format_t.write_image:add_return("boolean",[[Returns true on success.]])

types.dt_imageio_module_format_data_png:set_text([[Type object describing parameters to export to png.]])
types.dt_imageio_module_format_data_png.bpp:set_text([[The bpp parameter to use when exporting.]])
types.dt_imageio_module_format_data_tiff:set_text([[Type object describing parameters to export to tiff.]])
types.dt_imageio_module_format_data_tiff.bpp:set_text([[The bpp parameter to use when exporting.]])
types.dt_imageio_module_format_data_exr:set_text([[Type object describing parameters to export to exr.]])
types.dt_imageio_module_format_data_copy:set_text([[Type object describing parameters to export to copy.]])
types.dt_imageio_module_format_data_pfm:set_text([[Type object describing parameters to export to pfm.]])
types.dt_imageio_module_format_data_jpeg:set_text([[Type object describing parameters to export to jpeg.]])
types.dt_imageio_module_format_data_jpeg.quality:set_text([[The quality to use at export time.]])
types.dt_imageio_module_format_data_ppm:set_text([[Type object describing parameters to export to ppm.]])
types.dt_imageio_module_format_data_webp:set_text([[Type object describing parameters to export to webp.]])
types.dt_imageio_module_format_data_webp.quality:set_text([[The quality to use at export time.]])
types.dt_imageio_module_format_data_webp.comp_type:set_text([[The overall quality to use; can be one of "webp_lossy" or "webp_lossless".]]);
types.dt_imageio_module_format_data_webp.hint:set_text([[A hint on the overall content of the image, can be one of "hint_default", "hint_picture", "hint_photo", "hint_graphic".]])
types.dt_imageio_module_format_data_j2k:set_text([[Type object describing parameters to export to jpeg2000.]])
types.dt_imageio_module_format_data_j2k.quality:set_text([[The quality to use at export time.]])
types.dt_imageio_module_format_data_j2k.bpp:set_text([[The bpp parameter to use when exporting.]])
types.dt_imageio_module_format_data_j2k.format:set_text([[The format to use can be one of "j2k" or "jp2".]])
types.dt_imageio_module_format_data_j2k.preset:set_text([[The preset to use can be one of "cinema2k_24", "cinema2k_48", "cinema4k_24".]])


types.dt_imageio_module_storage_t:set_text([[A virtual type representing all storage types.]])
types.dt_imageio_module_storage_t.plugin_name:set_text([[A unique name for the plugin.]])
types.dt_imageio_module_storage_t.name:set_text([[A human readable name for the plugin.]])
types.dt_imageio_module_storage_t.width:set_text([[The currently selected width for the plugin.]])
types.dt_imageio_module_storage_t.height:set_text([[The currently selected height for the plugin.]])
types.dt_imageio_module_storage_t.recommended_width:set_text([[The recommended width for the plugin.]])
types.dt_imageio_module_storage_t.recommended_height:set_text([[The recommended height for the plugin.]])
types.dt_imageio_module_storage_t.supports_format:set_text([[Checks if a format is supported by this storage.]])
types.dt_imageio_module_storage_t.supports_format:add_parameter("storage",my_tostring(types.dt_imageio_module_storage_t),[[The storage type to check against.]])
types.dt_imageio_module_storage_t.supports_format:add_parameter("format",my_tostring(types.dt_imageio_module_format_t),[[The format type to check.]])
types.dt_imageio_module_storage_t.supports_format:add_return("boolean",[[True if the format is supported by the storage.]])

types.dt_imageio_module_storage_data_email:set_text([[An object containing parameters to export to email.]])
types.dt_imageio_module_storage_data_flickr:set_text([[An object containing parameters to export to flickr.]])
types.dt_imageio_module_storage_data_facebook:set_text([[An object containing parameters to export to facebook.]])
types.dt_imageio_module_storage_data_latex:set_text([[An object containing parameters to export to latex.]])
types.dt_imageio_module_storage_data_latex.filename:set_text([[The filename to export to.]])
types.dt_imageio_module_storage_data_latex.title:set_text([[The title to use for export.]])
types.dt_imageio_module_storage_data_picasa:set_text([[An object containing parameters to export to picasa.]])
types.dt_imageio_module_storage_data_gallery:set_text([[An object containing parameters to export to gallery.]])
types.dt_imageio_module_storage_data_gallery.filename:set_text([[The filename to export to.]])
types.dt_imageio_module_storage_data_gallery.title:set_text([[The title to use for export.]])
types.dt_imageio_module_storage_data_disk:set_text([[An object containing parameters to export to disk.]])
types.dt_imageio_module_storage_data_disk.filename:set_text([[The filename to export to.]])

types.dt_lua_film_t:set_text([[A film in darktable; this represents a directory containing imported images.]])
types.dt_lua_film_t["#"]:set_text([[The different images within the film.]])
types.dt_lua_film_t.id:set_text([[A unique numeric id used by this film.]])
types.dt_lua_film_t.path:set_text([[The path represented by this film.]])
types.dt_lua_film_t.delete:set_text([[Removes the film from the database.]])
types.dt_lua_film_t.delete:add_parameter("film",my_tostring(types.dt_lua_film_t),[[The film to remove.]])
types.dt_lua_film_t.delete:add_parameter("force","Boolean",[[Force removal, even if the film is not empty.]]):set_attribute("optional",true)
types.dt_lua_film_t.delete:add_version_info("function added")

types.dt_style_t:set_text([[A style that can be applied to an image.]])
types.dt_style_t.name:set_text([[The name of the style.]])
types.dt_style_t.description:set_text([[The description of the style.]])
types.dt_style_t["#"]:set_text([[The different items that make the style.]])

types.dt_style_item_t:set_text([[An element that is part of a style.]])
types.dt_style_item_t.name:set_text([[The name of the style item.]])
types.dt_style_item_t.num:set_text([[The position of the style item within its style.]])

types.dt_lua_tag_t:set_text([[A tag that can be attached to an image.]])
types.dt_lua_tag_t.name:set_text([[The name of the tag.]])
types.dt_lua_tag_t["#"]:set_text([[The images that have that tag attached to them.]])

types.dt_lib_module_t:set_text([[The type of a UI lib]])
types.dt_lib_module_t:add_version_info([[Type added]])
types.dt_lib_module_t.id:set_text([[A unit string identifying the lib]])
types.dt_lib_module_t.name:set_text([[The translated title of the UI element]])
types.dt_lib_module_t.version:set_text([[The version of the internal data of this lib]])
types.dt_lib_module_t.visible:set_text([[Allow to make a lib module completely invisible to the user.]]..para()..
[[Note that if the module is invisible the user will have no way to restore it without lua]])
types.dt_lib_module_t.visible:set_attribute("implicit_yield",true)
types.dt_lib_module_t.container:set_text([[The location of the lib in the darktable UI]])
types.dt_lib_module_t.expandable:set_text([[True if the lib can be expanded/retracted]]);
types.dt_lib_module_t.expanded:set_text([[True if the lib is expanded]]);
types.dt_lib_module_t.position:set_text([[A value deciding the position of the lib within its container]])
types.dt_lib_module_t.views:set_text([[A table of all teh views that display this widget]])
types.dt_lib_module_t.reset:set_text([[A function to reset the lib to its default values]]..para()..
[[This function will do nothing if the lib is not visible or can't be reset]])
types.dt_lib_module_t.reset:add_parameter("self",my_tostring(types.dt_lib_module_t),[[The lib to reset]])
types.dt_lib_module_t.on_screen:set_text([[True if the lib is currently visible on the screen]])

types.dt_view_t:set_text([[A darktable view]])
types.dt_view_t:add_version_info([[Type added]])
types.dt_view_t.id:set_text([[A unique string identifying the view]])
types.dt_view_t.name:set_text([[The name of the view]])


types.dt_lua_backgroundjob_t:set_text([[A lua-managed entry in the backgroundjob lib]]):add_version_info("type added")
types.dt_lua_backgroundjob_t.percent:set_text([[The value of the progress bar. nil if there is no progress bar]])
types.dt_lua_backgroundjob_t.valid:set_text([[True if the job is displayed, set it to false to destroy the entry]]..para().."An invalid job cannot be made valid again")


types.dt_lua_snapshot_t:set_text([[The description of a snapshot in the snapshot lib]]):add_version_info("type added")
types.dt_lua_snapshot_t.filename:set_text([[The filename of an image containing the snapshot]])
types.dt_lua_snapshot_t.select:set_text([[Activates this snapshot on the display. To deactivate all snapshot you need to call this function on the active snapshot]])
types.dt_lua_snapshot_t.select:add_parameter("snapshot",my_tostring(types.dt_lua_snapshot_t),[[The snapshot to activate]])
types.dt_lua_snapshot_t.name:set_text([[The name of the snapshot, as seen in the UI]])


----------------------
--  EVENTS          --
----------------------
events:set_text([[This section documents events that can be used to trigger Lua callbacks.]])


events["intermediate-export-image"]:set_text([[This event is called each time an image is exported, once for each image after the image has been processed to an image format but before the storage has moved the image to its final destination.]])
events["intermediate-export-image"].callback:add_parameter("event","string",[[The name of the event that triggered the callback.]])
events["intermediate-export-image"].callback:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image object that has been exported.]])
events["intermediate-export-image"].callback:add_parameter("filename","string",[[The name of the file that is the result of the image being processed.]])
events["intermediate-export-image"].callback:add_parameter("format",my_tostring(types.dt_imageio_module_format_t),[[The format used to export the image.]]):add_version_info([[field added]])
events["intermediate-export-image"].callback:add_parameter("storage",my_tostring(types.dt_imageio_module_storage_t),[[The storage used to export the image (can be nil).]]):add_version_info([[field added]])
events["intermediate-export-image"].extra_registration_parameters:set_text([[This event has no extra registration parameters.]])


events["post-import-image"]:set_text([[This event is triggered whenever a new image is imported into the database.

This event can be registered multiple times, all callbacks will be called.]])
events["post-import-image"].callback:add_parameter("event","string",[[The name of the event that triggered the callback.]])
events["post-import-image"].callback:add_parameter("image",my_tostring(types.dt_lua_image_t),[[The image object that has been exported.]])
events["post-import-image"].extra_registration_parameters:set_text([[This event has no extra registration parameters.]])


events["shortcut"]:set_text([[This event registers a new keyboad shortcut. The shortcut isn't bound to any key until the users does so in the preference panel.

The event is triggered whenever the shortcut is triggered.


This event can only be registered once per value of shortcut.
]])
events["shortcut"].callback:add_parameter("event","string",[[The name of the event that triggered the callback.]])

events["shortcut"].callback:add_parameter("shortcut","string",[[The tooltip string that was given at registration time.]])
events["shortcut"].extra_registration_parameters:set_text("")
events["shortcut"].extra_registration_parameters:add_parameter("tooltip","string",[[The string that will be displayed on the shortcut preference panel describing the shortcut.]])


events["post-import-film"]:set_text([[This event is triggered when an film import is finished (all post-import-image callbacks have already been triggered). This event can be registered multiple times.
]])
events["post-import-film"].callback:add_parameter("event","string",[[The name of the event that triggered the callback.]])

events["post-import-film"].callback:add_parameter("film",my_tostring(types.dt_lua_film_t),[[The new film that has been added. If multiple films were added recursively only the top level film is reported.]])
events["post-import-film"].extra_registration_parameters:set_text([[This event has no extra registration parameters.]])
events["view-changed"]:set_text([[This event is triggered after the user changed the active view]])
events["view-changed"].callback:add_parameter("old_view",my_tostring(types.dt_view_t),[[The view that we just left]])
events["view-changed"].callback:add_parameter("new_view",my_tostring(types.dt_view_t),[[The view we are now in]])
events["view-changed"].extra_registration_parameters:set_text([[This event has no extra registration parameters.]])
----------------------
--  ATTRIBUTES      --
----------------------
function invisible_attr(attr)
	attr:set_skiped()
	attr:set_attribute("internal_attr",true);
end
attributes:set_text([[This section documents various attributes used throughout the documentation.]])
invisible_attr(attributes.ret_val)
invisible_attr(attributes.signature)
invisible_attr(attributes.reported_type)
invisible_attr(attributes.is_singleton)
invisible_attr(attributes.optional)
invisible_attr(attributes.skiped)
invisible_attr(attributes.is_attribute)
invisible_attr(attributes.internal_attr)
attributes.write:set_text([[This object is a variable that can be written to.]])
attributes.read:set_text([[This object is a variable that can be read.]])
attributes.has_pairs:set_text([[This object can be used as an argument to the system function "pairs" and iterated upon.]])
attributes.has_ipairs:set_text([[This object can be used as an argument to the system function "ipairs" and iterated upon.]])
--attributes.has_equal:set_text([[This object has a specific comparison function that will be used when comparing it to an object of the same type.]])
attributes.has_length:set_text([[This object has a specific length function that will be used by the # operator.]])
attributes.has_tostring:set_text([[This object has a specific reimplementation of the "tostring" method that allows pretty-printing it.]])
attributes.implicit_yield:set_text([[This call will release the Lua lock while executing, thus allowing other Lua callbacks to run.]])
attributes.parent:set_text([[This object inherits some methods from another object. You can call the methods from the parent on the child object]])
attributes.views:set_skiped();
attributes.position:set_skiped();
attributes.container:set_skiped();

----------------------
--  SYSTEM          --
----------------------
doc.toplevel.system = doc.create_documentation_node(nil,doc.toplevel,"system")
local system = doc.toplevel.system
system:set_text([[This section documents changes to system functions.]])

doc.toplevel.system.coroutine = doc.create_documentation_node(nil,doc.toplevel.system,"coroutine")
system.coroutine:set_text("")
system.coroutine.yield = doc.document_function(nil,system.coroutine,"yield");
system.coroutine.yield:set_real_name("coroutine.yield")
system.coroutine.yield:set_text([[Lua functions can yield at any point. The parameters and return types depend on why we want to yield.]]..para()..
[[A callback that is yielding allows other Lua code to run.]]..startlist()..
listel("wait_ms: one extra parameter; the execution will pause for that many miliseconds; yield returns nothing;")..
listel("file_readable: an opened file from a call to the OS library; will return when the file is readable; returns nothing;")..
listel([[* run_command: a command to be run by "sh -c"; will return when the command terminates; returns the return code of the execution.]])..
endlist())
system.coroutine.yield:add_parameter("type","string",[[The type of yield; can be one of "wait_ms", "file_readable", "run_command".]])
system.coroutine.yield:add_parameter("extra","variable",[[An extra parameter: integer for "wait_ms", open file for "file_readable", string for "run_command".]])
system.coroutine.yield:add_return("variable",[[Nothing for "wait_ms" and "file_readable"; the returned code of the command for "run_command".]])
