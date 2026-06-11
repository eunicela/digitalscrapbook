import AsyncStorage from "@react-native-async-storage/async-storage";
import { StatusBar } from "expo-status-bar";
import * as ImagePicker from "expo-image-picker";
import { useEffect, useMemo, useRef, useState } from "react";
import {
  Animated,
  KeyboardAvoidingView,
  PanResponder,
  Platform,
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View
} from "react-native";
import { PageCanvas } from "./src/components/PageCanvas";
import { ScrapbookElementView } from "./src/components/ScrapbookElementView";
import { backgroundLabels, canvas, colors, sampleScrapbook } from "./src/data/sampleScrapbook";
import type {
  BackgroundStyle,
  ElementKind,
  Scrapbook,
  ScrapbookElement,
  ScrapbookPage,
  Screen
} from "./src/types/scrapbook";

const STORAGE_KEY = "digital-scrapbook:v1";

export default function App() {
  const [screen, setScreen] = useState<Screen>("library");
  const [scrapbooks, setScrapbooks] = useState<Scrapbook[]>([sampleScrapbook]);
  const [selectedBookID, setSelectedBookID] = useState(sampleScrapbook.id);
  const [currentPageIndex, setCurrentPageIndex] = useState(0);
  const [selectedElementID, setSelectedElementID] = useState<string | null>(null);
  const [newBookTitle, setNewBookTitle] = useState("");
  const [hydrated, setHydrated] = useState(false);
  const flipProgress = useRef(new Animated.Value(0)).current;

  const selectedBook = useMemo(
    () => scrapbooks.find((book) => book.id === selectedBookID) ?? scrapbooks[0],
    [scrapbooks, selectedBookID]
  );
  const currentPage = selectedBook.pages[currentPageIndex] ?? selectedBook.pages[0];
  const selectedElement = currentPage?.elements.find((element) => element.id === selectedElementID) ?? null;

  useEffect(() => {
    void loadScrapbooks();
  }, []);

  useEffect(() => {
    if (hydrated) {
      void AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(scrapbooks));
    }
  }, [hydrated, scrapbooks]);

  const flipResponder = useMemo(
    () =>
      PanResponder.create({
        onMoveShouldSetPanResponder: (_, gesture) => Math.abs(gesture.dx) > 20,
        onPanResponderRelease: (_, gesture) => {
          if (gesture.dx < -35) {
            goToPage(1);
          } else if (gesture.dx > 35) {
            goToPage(-1);
          }
        }
      }),
    [currentPageIndex, selectedBook.pages.length]
  );

  async function loadScrapbooks() {
    const stored = await AsyncStorage.getItem(STORAGE_KEY);
    if (stored) {
      const parsed = JSON.parse(stored) as Scrapbook[];
      if (parsed.length > 0) {
        setScrapbooks(parsed);
        setSelectedBookID(parsed[0].id);
      }
    }
    setHydrated(true);
  }

  function updateSelectedBook(updater: (book: Scrapbook) => Scrapbook) {
    setScrapbooks((books) =>
      books.map((book) =>
        book.id === selectedBook.id ? { ...updater(book), updatedAt: new Date().toISOString() } : book
      )
    );
  }

  function updateCurrentPage(updater: (page: ScrapbookPage) => ScrapbookPage) {
    updateSelectedBook((book) => ({
      ...book,
      pages: book.pages.map((page) => (page.id === currentPage.id ? updater(page) : page))
    }));
  }

  function createBook() {
    const title = newBookTitle.trim() || "Untitled Scrapbook";
    const book: Scrapbook = {
      id: makeID("book"),
      title,
      updatedAt: new Date().toISOString(),
      pages: [
        {
          id: makeID("page"),
          background: "warmPaper",
          elements: []
        }
      ]
    };
    setScrapbooks((books) => [book, ...books]);
    setSelectedBookID(book.id);
    setCurrentPageIndex(0);
    setNewBookTitle("");
    setScreen("flip");
  }

  function addPage() {
    const backgrounds = Object.keys(backgroundLabels) as BackgroundStyle[];
    const background = backgrounds[selectedBook.pages.length % backgrounds.length];
    updateSelectedBook((book) => ({
      ...book,
      pages: [
        ...book.pages,
        {
          id: makeID("page"),
          background,
          elements: []
        }
      ]
    }));
    setCurrentPageIndex(selectedBook.pages.length);
  }

  function goToPage(direction: -1 | 1) {
    const nextIndex = currentPageIndex + direction;
    if (nextIndex < 0 || nextIndex >= selectedBook.pages.length) {
      return;
    }

    flipProgress.setValue(0);
    Animated.timing(flipProgress, {
      toValue: 1,
      duration: 320,
      useNativeDriver: true
    }).start(() => {
      setCurrentPageIndex(nextIndex);
      flipProgress.setValue(0);
    });
  }

  async function addPhoto() {
    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) {
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      quality: 0.82,
      base64: true
    });

    if (result.canceled || result.assets.length === 0) {
      return;
    }

    const asset = result.assets[0];
    const uri = asset.base64 ? `data:image/jpeg;base64,${asset.base64}` : asset.uri;
    addElement("photo", { uri, text: "Imported photo", width: 158, height: 122, style: "image" });
  }

  function addElement(
    kind: ElementKind,
    overrides: Partial<Pick<ScrapbookElement, "text" | "style" | "uri" | "width" | "height">> = {}
  ) {
    const nextZIndex = Math.max(0, ...currentPage.elements.map((element) => element.zIndex)) + 1;
    const element: ScrapbookElement = {
      id: makeID(kind),
      kind,
      x: 170 - (overrides.width ?? 120) / 2,
      y: 205 - (overrides.height ?? 80) / 2,
      width: overrides.width ?? defaultSize(kind).width,
      height: overrides.height ?? defaultSize(kind).height,
      rotation: handmadeRotation(),
      zIndex: nextZIndex,
      text: overrides.text ?? defaultText(kind),
      style: overrides.style ?? defaultStyle(kind),
      uri: overrides.uri
    };

    updateCurrentPage((page) => ({
      ...page,
      elements: [...page.elements, element]
    }));
    setSelectedElementID(element.id);
  }

  function patchElement(id: string, patch: Partial<ScrapbookElement>) {
    updateCurrentPage((page) => ({
      ...page,
      elements: page.elements.map((element) => (element.id === id ? { ...element, ...patch } : element))
    }));
  }

  function deleteSelectedElement() {
    if (!selectedElementID) {
      return;
    }
    updateCurrentPage((page) => ({
      ...page,
      elements: page.elements.filter((element) => element.id !== selectedElementID)
    }));
    setSelectedElementID(null);
  }

  function bringForward() {
    if (!selectedElement) {
      return;
    }
    patchElement(selectedElement.id, {
      zIndex: Math.max(0, ...currentPage.elements.map((element) => element.zIndex)) + 1
    });
  }

  function sendBackward() {
    if (!selectedElement) {
      return;
    }
    patchElement(selectedElement.id, {
      zIndex: Math.min(0, ...currentPage.elements.map((element) => element.zIndex)) - 1
    });
  }

  function renderLibrary() {
    return (
      <SafeAreaView style={styles.libraryScreen}>
        <StatusBar style="light" />
        <ScrollView contentContainerStyle={styles.libraryContent}>
          <View style={styles.hero}>
            <Text style={styles.heroTitle}>Digital Scrapbook</Text>
            <Text style={styles.heroSubtitle}>
              Testable on your iPhone with Expo Go. Build handmade pages with photos, stickers, tape, dates, and scraps.
            </Text>
          </View>

          <View style={styles.createCard}>
            <Text style={styles.createTitle}>Start a new book</Text>
            <View style={styles.createRow}>
              <TextInput
                value={newBookTitle}
                onChangeText={setNewBookTitle}
                placeholder="Weekend memories"
                style={styles.createInput}
              />
              <Pressable style={styles.roundButton} onPress={createBook}>
                <Text style={styles.roundButtonText}>+</Text>
              </Pressable>
            </View>
          </View>

          {scrapbooks.map((book) => (
            <Pressable
              key={book.id}
              style={styles.bookCard}
              onPress={() => {
                setSelectedBookID(book.id);
                setCurrentPageIndex(0);
                setScreen("flip");
              }}
            >
              <View style={styles.bookCover}>
                <View style={styles.bookSpine} />
                <View style={styles.coverPreview}>
                  <PageCanvas page={book.pages[0]} pageNumber={1} totalPages={book.pages.length} />
                </View>
              </View>
              <View style={styles.bookDetails}>
                <Text style={styles.bookTitle}>{book.title}</Text>
                <Text style={styles.bookMeta}>
                  {book.pages.length} {book.pages.length === 1 ? "page" : "pages"}
                </Text>
                <Text style={styles.bookHint}>Open and flip through pages</Text>
              </View>
              <Text style={styles.chevron}>›</Text>
            </Pressable>
          ))}
        </ScrollView>
      </SafeAreaView>
    );
  }

  function renderFlip() {
    const rotateY = flipProgress.interpolate({
      inputRange: [0, 1],
      outputRange: ["0deg", "-72deg"]
    });
    const translateX = flipProgress.interpolate({
      inputRange: [0, 1],
      outputRange: [0, -42]
    });

    return (
      <SafeAreaView style={styles.flipScreen}>
        <StatusBar style="light" />
        <View style={styles.topBar}>
          <Pressable onPress={() => setScreen("library")} style={styles.navPill}>
            <Text style={styles.navPillText}>Library</Text>
          </Pressable>
          <Pressable onPress={addPage} style={styles.navPill}>
            <Text style={styles.navPillText}>+ Page</Text>
          </Pressable>
        </View>

        <Text style={styles.flipTitle}>{selectedBook.title}</Text>
        <Text style={styles.flipSubtitle}>
          {selectedBook.pages.length} {selectedBook.pages.length === 1 ? "page" : "pages"}
        </Text>

        <View style={styles.bookStage} {...flipResponder.panHandlers}>
          <View style={[styles.stackedPage, styles.stackedPageBack]} />
          <View style={[styles.stackedPage, styles.stackedPageMiddle]} />
          <Animated.View
            style={[
              styles.flipPage,
              {
                transform: [{ perspective: 850 }, { translateX }, { rotateY }]
              }
            ]}
          >
            <PageCanvas page={currentPage} pageNumber={currentPageIndex + 1} totalPages={selectedBook.pages.length} />
          </Animated.View>
        </View>

        <Text style={styles.pageCounter}>
          Page {currentPageIndex + 1} of {selectedBook.pages.length}
        </Text>

        <View style={styles.flipControls}>
          <Pressable style={styles.secondaryButton} onPress={() => goToPage(-1)}>
            <Text style={styles.secondaryButtonText}>Previous</Text>
          </Pressable>
          <Pressable style={styles.primaryButton} onPress={() => setScreen("editor")}>
            <Text style={styles.primaryButtonText}>Customize page</Text>
          </Pressable>
          <Pressable style={styles.secondaryButton} onPress={() => goToPage(1)}>
            <Text style={styles.secondaryButtonText}>Next</Text>
          </Pressable>
        </View>
      </SafeAreaView>
    );
  }

  function renderEditor() {
    return (
      <KeyboardAvoidingView behavior={Platform.OS === "ios" ? "padding" : undefined} style={styles.editorScreen}>
        <StatusBar style="light" />
        <SafeAreaView style={styles.editorSafeArea}>
          <View style={styles.editorTopBar}>
            <Pressable onPress={() => setScreen("flip")} style={styles.navPill}>
              <Text style={styles.navPillText}>Done</Text>
            </Pressable>
            <Text style={styles.editorTitle}>Customize Page</Text>
            <Pressable
              onPress={deleteSelectedElement}
              style={[styles.navPill, !selectedElement && styles.disabledPill]}
              disabled={!selectedElement}
            >
              <Text style={styles.navPillText}>Delete</Text>
            </Pressable>
          </View>

          <View style={styles.editorCanvasWrap}>
            <PageCanvas
              page={currentPage}
              selectedElementID={selectedElementID}
              renderInteractiveElement={(element) => (
                <DraggableElement
                  key={element.id}
                  element={element}
                  selected={selectedElementID === element.id}
                  onSelect={() => setSelectedElementID(element.id)}
                  onMove={(x, y) => patchElement(element.id, { x, y })}
                />
              )}
            />
          </View>

          {selectedElement ? (
            <View style={styles.inspector}>
              <Text style={styles.inspectorLabel}>Selected {selectedElement.kind}</Text>
              {selectedElement.kind !== "photo" && selectedElement.kind !== "tape" ? (
                <TextInput
                  value={selectedElement.text}
                  onChangeText={(text) => patchElement(selectedElement.id, { text })}
                  style={styles.inspectorInput}
                  placeholder="Edit text"
                />
              ) : null}
              <View style={styles.inspectorControls}>
                <Pressable style={styles.miniButton} onPress={() => patchElement(selectedElement.id, { rotation: selectedElement.rotation - 6 })}>
                  <Text style={styles.miniButtonText}>Rotate -</Text>
                </Pressable>
                <Pressable style={styles.miniButton} onPress={() => patchElement(selectedElement.id, { rotation: selectedElement.rotation + 6 })}>
                  <Text style={styles.miniButtonText}>Rotate +</Text>
                </Pressable>
                <Pressable
                  style={styles.miniButton}
                  onPress={() =>
                    patchElement(selectedElement.id, {
                      width: Math.max(32, selectedElement.width - 12),
                      height: Math.max(28, selectedElement.height - 10)
                    })
                  }
                >
                  <Text style={styles.miniButtonText}>Smaller</Text>
                </Pressable>
                <Pressable
                  style={styles.miniButton}
                  onPress={() =>
                    patchElement(selectedElement.id, {
                      width: selectedElement.width + 12,
                      height: selectedElement.height + 10
                    })
                  }
                >
                  <Text style={styles.miniButtonText}>Bigger</Text>
                </Pressable>
                <Pressable style={styles.miniButton} onPress={sendBackward}>
                  <Text style={styles.miniButtonText}>Back</Text>
                </Pressable>
                <Pressable style={styles.miniButton} onPress={bringForward}>
                  <Text style={styles.miniButtonText}>Front</Text>
                </Pressable>
              </View>
            </View>
          ) : null}

          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.toolScroller}>
            <View style={styles.toolRow}>
              <ToolButton label="Photo" onPress={addPhoto} />
              <ToolButton label="Text" onPress={() => addElement("text")} />
              <ToolButton label="Sticker" onPress={() => addElement("sticker", { text: randomSticker() })} />
              <ToolButton label="Tape" onPress={() => addElement("tape")} />
              <ToolButton label="Date" onPress={() => addElement("dateNumber")} />
              <ToolButton label="Scrap" onPress={() => addElement("paperScrap")} />
            </View>
          </ScrollView>

          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.backgroundScroller}>
            <View style={styles.backgroundRow}>
              <Text style={styles.backgroundLabel}>Paper</Text>
              {(Object.keys(backgroundLabels) as BackgroundStyle[]).map((background) => (
                <Pressable
                  key={background}
                  onPress={() => updateCurrentPage((page) => ({ ...page, background }))}
                  style={[styles.backgroundChip, currentPage.background === background && styles.activeBackgroundChip]}
                >
                  <Text style={[styles.backgroundChipText, currentPage.background === background && styles.activeBackgroundChipText]}>
                    {backgroundLabels[background]}
                  </Text>
                </Pressable>
              ))}
            </View>
          </ScrollView>
        </SafeAreaView>
      </KeyboardAvoidingView>
    );
  }

  if (!currentPage) {
    return null;
  }

  if (screen === "library") {
    return renderLibrary();
  }

  if (screen === "flip") {
    return renderFlip();
  }

  return renderEditor();
}

type DraggableElementProps = {
  element: ScrapbookElement;
  selected: boolean;
  onSelect: () => void;
  onMove: (x: number, y: number) => void;
};

function DraggableElement({ element, selected, onSelect, onMove }: DraggableElementProps) {
  const start = useRef({ x: element.x, y: element.y });
  const responder = useMemo(
    () =>
      PanResponder.create({
        onStartShouldSetPanResponder: () => true,
        onMoveShouldSetPanResponder: () => true,
        onPanResponderGrant: () => {
          start.current = { x: element.x, y: element.y };
          onSelect();
        },
        onPanResponderMove: (_, gesture) => {
          onMove(
            clamp(start.current.x + gesture.dx, -element.width / 2, canvas.width - element.width / 2),
            clamp(start.current.y + gesture.dy, -element.height / 2, canvas.height - element.height / 2)
          );
        }
      }),
    [element.height, element.width, element.x, element.y, onMove, onSelect]
  );

  return (
    <View {...responder.panHandlers}>
      <ScrapbookElementView element={element} selected={selected} />
    </View>
  );
}

type ToolButtonProps = {
  label: string;
  onPress: () => void;
};

function ToolButton({ label, onPress }: ToolButtonProps) {
  return (
    <Pressable style={styles.toolButton} onPress={onPress}>
      <Text style={styles.toolButtonText}>{label}</Text>
    </Pressable>
  );
}

function makeID(prefix: string) {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

function handmadeRotation() {
  return Math.round(Math.random() * 14 - 7);
}

function randomSticker() {
  const stickers = ["★", "✦", "♡", "✿", "✶"];
  return stickers[Math.floor(Math.random() * stickers.length)];
}

function defaultSize(kind: ElementKind) {
  switch (kind) {
    case "photo":
      return { width: 150, height: 116 };
    case "text":
      return { width: 154, height: 58 };
    case "sticker":
      return { width: 58, height: 58 };
    case "tape":
      return { width: 96, height: 28 };
    case "dateNumber":
      return { width: 102, height: 90 };
    case "paperScrap":
      return { width: 156, height: 120 };
    default:
      return { width: 120, height: 80 };
  }
}

function defaultText(kind: ElementKind) {
  switch (kind) {
    case "text":
      return "new little note";
    case "sticker":
      return "★";
    case "dateNumber":
      return "26";
    case "paperScrap":
      return "little moments";
    default:
      return "";
  }
}

function defaultStyle(kind: ElementKind) {
  switch (kind) {
    case "paperScrap":
      return "redStripe";
    case "tape":
      return "cream";
    default:
      return "";
  }
}

function clamp(value: number, minimum: number, maximum: number) {
  return Math.min(Math.max(value, minimum), maximum);
}

const styles = StyleSheet.create({
  libraryScreen: {
    flex: 1,
    backgroundColor: colors.ink
  },
  libraryContent: {
    padding: 20,
    paddingBottom: 36,
    gap: 18
  },
  hero: {
    gap: 8,
    marginTop: 10,
    marginBottom: 4
  },
  heroTitle: {
    color: "#ffffff",
    fontSize: 34,
    fontWeight: "900",
    letterSpacing: -1
  },
  heroSubtitle: {
    color: "rgba(255, 255, 255, 0.74)",
    fontSize: 15,
    fontWeight: "600",
    lineHeight: 22
  },
  createCard: {
    gap: 12,
    padding: 16,
    borderRadius: 24,
    backgroundColor: "rgba(255, 255, 255, 0.96)"
  },
  createTitle: {
    color: colors.charcoal,
    fontSize: 17,
    fontWeight: "900"
  },
  createRow: {
    flexDirection: "row",
    gap: 10
  },
  createInput: {
    flex: 1,
    height: 48,
    paddingHorizontal: 14,
    borderRadius: 16,
    backgroundColor: "#f4f1eb",
    color: colors.charcoal,
    fontSize: 16,
    fontWeight: "700"
  },
  roundButton: {
    width: 48,
    height: 48,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 24,
    backgroundColor: colors.coral
  },
  roundButtonText: {
    color: "#ffffff",
    fontSize: 28,
    fontWeight: "500",
    marginTop: -2
  },
  bookCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
    padding: 16,
    borderRadius: 26,
    backgroundColor: "#ffffff"
  },
  bookCover: {
    width: 96,
    height: 128,
    overflow: "hidden",
    borderRadius: 18,
    backgroundColor: "#ede4cf"
  },
  coverPreview: {
    position: "absolute",
    left: -2,
    top: -1,
    width: canvas.width,
    height: canvas.height,
    transform: [{ scale: 0.29 }]
  },
  bookSpine: {
    position: "absolute",
    left: 0,
    top: 0,
    bottom: 0,
    zIndex: 20,
    width: 10,
    backgroundColor: "rgba(0, 0, 0, 0.12)"
  },
  bookDetails: {
    flex: 1,
    gap: 6
  },
  bookTitle: {
    color: colors.charcoal,
    fontSize: 21,
    fontWeight: "900"
  },
  bookMeta: {
    color: "#666666",
    fontSize: 14,
    fontWeight: "800"
  },
  bookHint: {
    color: "#888888",
    fontSize: 12,
    fontWeight: "700"
  },
  chevron: {
    color: "#999999",
    fontSize: 36,
    fontWeight: "300"
  },
  flipScreen: {
    flex: 1,
    alignItems: "center",
    backgroundColor: colors.ink
  },
  topBar: {
    width: "100%",
    flexDirection: "row",
    justifyContent: "space-between",
    paddingHorizontal: 18,
    paddingTop: 8
  },
  navPill: {
    minWidth: 76,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 14,
    height: 38,
    borderRadius: 19,
    backgroundColor: "rgba(255, 255, 255, 0.14)"
  },
  disabledPill: {
    opacity: 0.38
  },
  navPillText: {
    color: "#ffffff",
    fontSize: 13,
    fontWeight: "900"
  },
  flipTitle: {
    marginTop: 28,
    color: "#ffffff",
    fontSize: 29,
    fontWeight: "900",
    letterSpacing: -0.4
  },
  flipSubtitle: {
    marginTop: 6,
    color: "rgba(255, 255, 255, 0.72)",
    fontSize: 15,
    fontWeight: "800"
  },
  bookStage: {
    width: canvas.width + 38,
    height: canvas.height + 44,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 28
  },
  stackedPage: {
    position: "absolute",
    width: canvas.width,
    height: canvas.height,
    borderRadius: 22,
    backgroundColor: "#fffdf7"
  },
  stackedPageBack: {
    transform: [{ rotate: "3deg" }, { translateX: 17 }],
    opacity: 0.54
  },
  stackedPageMiddle: {
    transform: [{ rotate: "-2deg" }, { translateX: 9 }],
    opacity: 0.72
  },
  flipPage: {
    width: canvas.width,
    height: canvas.height
  },
  pageCounter: {
    color: "rgba(255, 255, 255, 0.72)",
    fontSize: 13,
    fontWeight: "900",
    marginTop: 6
  },
  flipControls: {
    width: "100%",
    flexDirection: "row",
    gap: 10,
    paddingHorizontal: 18,
    marginTop: 14
  },
  primaryButton: {
    flex: 1.25,
    height: 52,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 26,
    backgroundColor: "#ffffff"
  },
  primaryButtonText: {
    color: colors.ink,
    fontSize: 15,
    fontWeight: "900"
  },
  secondaryButton: {
    flex: 0.82,
    height: 52,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 26,
    backgroundColor: "rgba(255, 255, 255, 0.14)"
  },
  secondaryButtonText: {
    color: "#ffffff",
    fontSize: 13,
    fontWeight: "900"
  },
  editorScreen: {
    flex: 1,
    backgroundColor: "#222221"
  },
  editorSafeArea: {
    flex: 1
  },
  editorTopBar: {
    height: 56,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 14
  },
  editorTitle: {
    color: "#ffffff",
    fontSize: 17,
    fontWeight: "900"
  },
  editorCanvasWrap: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: colors.deepInk
  },
  inspector: {
    gap: 10,
    padding: 12,
    backgroundColor: "#2e2e2c"
  },
  inspectorLabel: {
    color: "rgba(255, 255, 255, 0.74)",
    fontSize: 12,
    fontWeight: "900",
    textTransform: "uppercase"
  },
  inspectorInput: {
    height: 40,
    paddingHorizontal: 12,
    borderRadius: 12,
    backgroundColor: "#ffffff",
    color: colors.charcoal,
    fontWeight: "800"
  },
  inspectorControls: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8
  },
  miniButton: {
    paddingHorizontal: 11,
    paddingVertical: 8,
    borderRadius: 16,
    backgroundColor: "rgba(255, 255, 255, 0.14)"
  },
  miniButtonText: {
    color: "#ffffff",
    fontSize: 12,
    fontWeight: "900"
  },
  toolScroller: {
    maxHeight: 78,
    backgroundColor: colors.toolbar
  },
  toolRow: {
    flexDirection: "row",
    gap: 10,
    paddingHorizontal: 14,
    paddingVertical: 10
  },
  toolButton: {
    width: 70,
    height: 56,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 18,
    backgroundColor: "rgba(255, 255, 255, 0.12)"
  },
  toolButtonText: {
    color: "#ffffff",
    fontSize: 12,
    fontWeight: "900"
  },
  backgroundScroller: {
    maxHeight: 60,
    backgroundColor: "#20201f"
  },
  backgroundRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 9,
    paddingHorizontal: 14,
    paddingVertical: 10
  },
  backgroundLabel: {
    color: "rgba(255, 255, 255, 0.72)",
    fontSize: 12,
    fontWeight: "900"
  },
  backgroundChip: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 18,
    backgroundColor: "rgba(255, 255, 255, 0.12)"
  },
  activeBackgroundChip: {
    backgroundColor: "#ffffff"
  },
  backgroundChipText: {
    color: "#ffffff",
    fontSize: 12,
    fontWeight: "900"
  },
  activeBackgroundChipText: {
    color: colors.ink
  }
});
