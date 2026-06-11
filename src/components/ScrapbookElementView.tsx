import { Image, StyleSheet, Text, View } from "react-native";
import type { ScrapbookElement } from "../types/scrapbook";
import { colors } from "../data/sampleScrapbook";

type Props = {
  element: ScrapbookElement;
  selected?: boolean;
};

export function ScrapbookElementView({ element, selected = false }: Props) {
  return (
    <View
      style={[
        styles.shell,
        {
          left: element.x,
          top: element.y,
          width: element.width,
          height: element.height,
          zIndex: element.zIndex,
          transform: [{ rotate: `${element.rotation}deg` }]
        },
        selected && styles.selected
      ]}
    >
      {renderElement(element)}
    </View>
  );
}

function renderElement(element: ScrapbookElement) {
  switch (element.kind) {
    case "photo":
      return (
        <View style={styles.photoFrame}>
          {element.uri ? (
            <Image source={{ uri: element.uri }} style={styles.photoImage} />
          ) : (
            <View style={styles.photoPlaceholder}>
              <Text style={styles.photoIcon}>photo</Text>
            </View>
          )}
        </View>
      );
    case "text":
      return (
        <View style={styles.caption}>
          <Text style={styles.captionText}>{element.text}</Text>
        </View>
      );
    case "sticker":
      return <Text style={styles.sticker}>{element.text || "★"}</Text>;
    case "tape":
      return (
        <View style={styles.tape}>
          {Array.from({ length: 8 }).map((_, index) => (
            <View key={index} style={styles.tapeLine} />
          ))}
        </View>
      );
    case "dateNumber":
      return <Text style={styles.dateNumber}>{element.text}</Text>;
    case "paperScrap":
      return (
        <View style={[styles.paperScrap, element.style === "redStripe" && styles.redScrap]}>
          <Text style={styles.paperScrapText}>{element.text}</Text>
        </View>
      );
    default:
      return null;
  }
}

const styles = StyleSheet.create({
  shell: {
    position: "absolute",
    alignItems: "center",
    justifyContent: "center"
  },
  selected: {
    borderWidth: 2,
    borderStyle: "dashed",
    borderColor: colors.coral,
    borderRadius: 12
  },
  photoFrame: {
    width: "100%",
    height: "100%",
    padding: 8,
    borderRadius: 8,
    backgroundColor: "#ffffff",
    shadowColor: "#000",
    shadowOpacity: 0.2,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 5 },
    elevation: 5
  },
  photoImage: {
    width: "100%",
    height: "100%",
    borderRadius: 5
  },
  photoPlaceholder: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 5,
    backgroundColor: "#78919d"
  },
  photoIcon: {
    color: "rgba(255, 255, 255, 0.85)",
    fontWeight: "800",
    letterSpacing: 0.5,
    textTransform: "uppercase"
  },
  caption: {
    width: "100%",
    height: "100%",
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 10,
    borderRadius: 10,
    backgroundColor: "rgba(255, 255, 255, 0.84)"
  },
  captionText: {
    color: colors.ink,
    fontSize: 13,
    fontWeight: "800",
    textAlign: "center"
  },
  sticker: {
    color: "#d33f2f",
    fontSize: 42,
    fontWeight: "900",
    textShadowColor: "#ffffff",
    textShadowRadius: 1
  },
  tape: {
    width: "100%",
    height: "100%",
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-around",
    borderRadius: 8,
    backgroundColor: "rgba(250, 228, 156, 0.82)"
  },
  tapeLine: {
    width: 3,
    height: "100%",
    backgroundColor: "rgba(255, 255, 255, 0.25)"
  },
  dateNumber: {
    color: colors.blue,
    fontSize: 70,
    fontWeight: "900",
    letterSpacing: -4
  },
  paperScrap: {
    width: "100%",
    height: "100%",
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 12,
    backgroundColor: "#f4e6bd",
    shadowColor: "#000",
    shadowOpacity: 0.14,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 3 },
    elevation: 3
  },
  redScrap: {
    backgroundColor: "#b9354a"
  },
  paperScrapText: {
    color: "rgba(255, 255, 255, 0.9)",
    fontWeight: "900",
    textAlign: "center"
  }
});
