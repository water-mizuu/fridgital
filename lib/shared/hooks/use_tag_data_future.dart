import "package:flutter_hooks/flutter_hooks.dart";
import "package:fridgital/back_end/tag_data.dart";

Future<TagData> useTagDataFuture() {
  late Future<TagData> tagDataFuture;

  useEffect(() {
    tagDataFuture = TagData.emptyFromDatabase();

    return () {
      tagDataFuture.then((tagData) => tagData.dispose());
    };
  });

  return tagDataFuture;
}
