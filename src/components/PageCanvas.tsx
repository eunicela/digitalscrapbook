import { StyleSheet, Text, View } from "react-native";
import { canvas } from "../data/sampleScrapbook";
import type { ScrapbookElement, ScrapbookPage } from "../types/scrapbook";
import { PageBackground } from "./PageBackground";
import { ScrapbookElementView } from "./ScrapbookElementView";

type Props = {
  page: ScrapbookPage;
  pageNumber?: number;
  totalPages?: number;
  selectedElementID?: string | null;
  onSelectElement?: (id: string) => void;
  renderInteractiveElement?: (element: ScrapbookElement) => React.ReactNode;
};

export function PageCanvas({
  page,
  pageNumber,
  totalPages,
  selectedElementID,
  onSelectElement,
  renderInteractiveElement
}: Props) {
  const sortedElements = [...page.elements].sort((first, second) => first.zIndex - second.zIndex);

  return (
    <View style={styles.page}>
      <PageBackground styleName={page.background} />

      {sortedElements.map((element) => {
        if (renderInteractiveElement) {
          return <View key={element.id}>{renderInteractiveElement(element)}</View>;
        }

        return (
          <View
            key={element.id}
            onTouchEnd={() => {
              onSelectElement?.(element.id);
            }}
          >
            <ScrapbookElementView element={element} selected={selectedElementID === element.id} />
          </View>
        );
      })}

      {pageNumber && totalPages ? (
        <View style={styles.pageNumbers}>
          <Text style={styles.pageNumber}>{pageNumber}</Text>
          <Text style={styles.pageNumber}>{totalPages}</Text>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  page: {
    width: canvas.width,
    height: canvas.height,
    overflow: "hidden",
    borderRadius: 22,
    backgroundColor: "#f6f1e7",
    shadowColor: "#000",
    shadowOpacity: 0.24,
    shadowRadius: 20,
    shadowOffset: { width: 0, height: 16 },
    elevation: 8
  },
  pageNumbers: {
    position: "absolute",
    left: 18,
    right: 18,
    bottom: 15,
    flexDirection: "row",
    justifyContent: "space-between"
  },
  pageNumber: {
    color: "rgba(0, 0, 0, 0.25)",
    fontSize: 11,
    fontWeight: "900"
  }
});
