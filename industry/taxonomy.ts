// PhytoPulse 行业配置；保留原框架分类、标签与主题机制。
export const CATEGORIES = [
  {
    "key": "paper",
    "label": "研究",
    "feedLabel": "研究论文",
    "section": "研究进展",
    "tagColor": "violet",
    "guide": "原创论文、临床试验与系统综述，按实际研究内容归类。"
  },
  {
    "key": "ingredients",
    "label": "原料",
    "section": "原料与应用",
    "tagColor": "green",
    "guide": "植物提取物、天然成分及功能性原料的发布、规格与应用。"
  },
  {
    "key": "efficacy",
    "label": "功效",
    "section": "功效研究",
    "tagColor": "turquoise",
    "guide": "以功效证据比较和应用解读为主，原创论文仍归研究。"
  },
  {
    "key": "process",
    "label": "工艺",
    "section": "工艺与质控",
    "tagColor": "indigo",
    "guide": "提取分离、制剂、分析检测及质量控制方法与实践。"
  },
  {
    "key": "regulation",
    "label": "法规",
    "section": "法规与标准",
    "tagColor": "orange",
    "guide": "正式法规、标准、监管公告及安全评估。"
  },
  {
    "key": "industry",
    "label": "产业",
    "section": "产业动态",
    "tagColor": "purple",
    "guide": "企业合作、产能、供应链及其他产业事件。"
  }
] as const;
export const CATEGORY_TAGS = [
  "论文/研究",
  "原料/应用",
  "功效解读",
  "工艺/质控",
  "政策/监管",
  "行业动态",
  "方法/实践",
  "观点/分析",
  "其他"
] as const;
export const TOPIC_TAGS = [
  "植物提取物",
  "天然活性成分",
  "功能食品",
  "皮肤健康",
  "代谢健康",
  "肠道健康",
  "提取分离",
  "分析检测",
  "制剂递送",
  "人体研究",
  "动物研究",
  "细胞研究",
  "系统综述"
] as const;
export const ENTITY_TAGS = [
  "Frontiers",
  "Europe PMC"
] as const;
export const ITEM_TYPES = [
  "research_paper",
  "review_paper",
  "product_launch",
  "method_update",
  "industry_event",
  "opinion_analysis",
  "tutorial_explainer"
] as const;
export const PLAIN_TERMS = [
  "doi",
  "hplc",
  "lc-ms",
  "ic50",
  "ec50",
  "rct",
  "天然产物",
  "功能性原料"
] as const;
export const RELEASE: { category: string; tag: string; unit: string } | null = null;
export const TAG_SYNONYMS: Readonly<Record<string,string>> = {"论文": "论文/研究", "综述": "系统综述", "提取工艺": "提取分离", "法规": "政策/监管", "临床试验": "人体研究"};
export const ENTITIES: Record<string, { name: string; displayTag: string | null; aliases: string[]; orgNames?: string[]; otherNames?: string[] }> = {"frontiers": {"name": "Frontiers", "displayTag": "Frontiers", "aliases": ["Frontiers"]}, "europe-pmc": {"name": "Europe PMC", "displayTag": "Europe PMC", "aliases": ["Europe PMC"]}};
export const IDENTITY_LEXICON: ReadonlyArray<{ id: string; name: string; patterns: RegExp[] }> = [];
export const PUBLISHER_DOMAINS: ReadonlyArray<{ entityId: string; domains: readonly string[] }> = [];
export const IDENTITY_CONTEXT_ALIASES: ReadonlyArray<{ entityId: string; pattern: RegExp }> = [];
