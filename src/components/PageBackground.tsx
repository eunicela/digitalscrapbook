import { StyleSheet, View } from "react-native";
import type { BackgroundStyle } from "../types/scrapbook";

type Props = {
  styleName: BackgroundStyle;
};

export function PageBackground({ styleName }: Props) {
  if (styleName === "blushStripe") {
    return (
      <View style={[StyleSheet.absoluteFill, styles.blush]}>
        {Array.from({ length: 13 }).map((_, index) => (
          <View key={index} style={[styles.verticalStripe, { left: index * 28 }]} />
        ))}
      </View>
    );
  }

  if (styleName === "blueGrid") {
    return (
      <View style={[StyleSheet.absoluteFill, styles.blueGrid]}>
        {Array.from({ length: 16 }).map((_, index) => (
          <View key={`v-${index}`} style={[styles.gridVertical, { left: index * 22 }]} />
        ))}
        {Array.from({ length: 22 }).map((_, index) => (
          <View key={`h-${index}`} style={[styles.gridHorizontal, { top: index * 22 }]} />
        ))}
      </View>
    );
  }

  if (styleName === "mintDots") {
    return (
      <View style={[StyleSheet.absoluteFill, styles.mint]}>
        {Array.from({ length: 140 }).map((_, index) => (
          <View
            key={index}
            style={[
              styles.dot,
              {
                left: 12 + (index % 14) * 24,
                top: 12 + Math.floor(index / 14) * 24
              }
            ]}
          />
        ))}
      </View>
    );
  }

  return <View style={[StyleSheet.absoluteFill, styleName === "kraft" ? styles.kraft : styles.paper]} />;
}

const styles = StyleSheet.create({
  paper: {
    backgroundColor: "#f6f1e7"
  },
  kraft: {
    backgroundColor: "#b29261"
  },
  blush: {
    backgroundColor: "#e9c0bd"
  },
  verticalStripe: {
    position: "absolute",
    top: 0,
    bottom: 0,
    width: 14,
    backgroundColor: "rgba(168, 42, 61, 0.34)"
  },
  blueGrid: {
    backgroundColor: "#e6f0f4"
  },
  gridVertical: {
    position: "absolute",
    top: 0,
    bottom: 0,
    width: 1,
    backgroundColor: "rgba(54, 99, 194, 0.14)"
  },
  gridHorizontal: {
    position: "absolute",
    left: 0,
    right: 0,
    height: 1,
    backgroundColor: "rgba(54, 99, 194, 0.14)"
  },
  mint: {
    backgroundColor: "#d2e8d7"
  },
  dot: {
    position: "absolute",
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: "rgba(255, 255, 255, 0.42)"
  }
});
