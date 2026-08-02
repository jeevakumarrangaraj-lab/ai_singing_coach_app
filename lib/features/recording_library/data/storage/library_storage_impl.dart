export 'library_storage_io.dart'
    if (dart.library.html) 'library_storage_web.dart'
    show createLibraryStorage;
