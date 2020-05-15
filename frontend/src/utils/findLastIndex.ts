const findLastIndex = <T>(arr: T[], func: (_: T) => boolean) => {
  const len = arr.length;
  const idx = [...arr].reverse().findIndex(func);
  return idx < 0 ? idx : len - idx - 1;
};

export default findLastIndex;
