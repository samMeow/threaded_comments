const rightMerge = <T>(ar1: T[], ar2: T[], identity: (_: T) => string): T[] => {
  const dict: { [k: string]: T } = ar1.reduce((memo, x) => ({
      ...memo,
      [identity(x)]: x,
  }), {});
  const temp = [...ar1];
  ar2.forEach((x) => {
    if (dict[identity(x)]) { return; }
    temp.push(x);
  });
  return temp;
};

export default rightMerge;
