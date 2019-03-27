# Introduction
The CartToShelf Koha plugin extends the existing functionality provided by the Koha the cron job misc/cronjobs/cart_to_shelf.pl. It allows the library staff to scan the books being placed back into their correct shelving location from the book cart when re-shelving them after a check-in, for libraries that have their ReturnToShelvingCart system preference set to 'Move'. The plugin allows for just-in-time updates to the document's location just as it is being actually placed back into the shelf.

### What is a Koha plugin
Koha’s Plugin System (available in Koha 3.12+) allows us to add additional tools and reports to [Koha](http://koha-community.org) that are specific to our library. Plugins are installed by uploading KPZ ( Koha Plugin Zip ) packages. A KPZ file is just a zip file containing the Perl files, template files, and any other files necessary to make the plugin work. 

# Downloading

From the [release page](/root/Koha/koha-plugin-cart-to-shelf/README.md) we can download the relevant *.kpz file

# Installing

Upload the KPZ ( Koha Plugin Zip ) package _(downloaded in the previous step)_ by going to `Administration -> Manage plugins -> Upload plugin`. 

### Preparations that are required before installation.
The plugin system needs to be turned on by a system administrator. To set up the Koha plugin system we must first make some changes to our Koha instance.

* Change `<enable_plugins>0<enable_plugins>` to `<enable_plugins>1</enable_plugins>` in your instance's koha-conf.xml file
* You will also need to **enable** your `UseKohaPlugins` system preference. 

# Configuring the plugin

The plugin requires no separate configuration

# Uninstalling

The plugin can be uninstalled by selecting the `Uninstall` option from the `Actions` drop-down for the **CartToShelf Plugin** plugin.
