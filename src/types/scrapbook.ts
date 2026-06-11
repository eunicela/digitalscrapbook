export type Screen = "library" | "flip" | "editor";

export type BackgroundStyle =
  | "warmPaper"
  | "blushStripe"
  | "blueGrid"
  | "kraft"
  | "mintDots";

export type ElementKind =
  | "photo"
  | "text"
  | "sticker"
  | "tape"
  | "dateNumber"
  | "paperScrap";

export type ScrapbookElement = {
  id: string;
  kind: ElementKind;
  x: number;
  y: number;
  width: number;
  height: number;
  rotation: number;
  zIndex: number;
  text: string;
  style: string;
  uri?: string;
};

export type ScrapbookPage = {
  id: string;
  background: BackgroundStyle;
  elements: ScrapbookElement[];
};

export type Scrapbook = {
  id: string;
  title: string;
  updatedAt: string;
  pages: ScrapbookPage[];
};
