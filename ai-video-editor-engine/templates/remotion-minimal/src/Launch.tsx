import { AbsoluteFill, Sequence, interpolate, spring, useCurrentFrame, useVideoConfig, Easing } from 'remotion';

// Every value is a pure function of the frame number: preview and render match.
const ACCENT = '#FF9900';          // replace with brand_profile.json primary
const STAGE = '#070707';

const Line = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const p = interpolate(frame, [0, fps * 0.9], [0, 1], { extrapolateRight: 'clamp', easing: Easing.out(Easing.exp) });
  return <div style={{ position: 'absolute', left: 560, top: 640, width: 800 * p, height: 6, background: ACCENT, borderRadius: 3, boxShadow: `0 0 24px ${ACCENT}` }} />;
};

const Headline = ({ text }: { text: string }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const words = text.split(' ');
  return (
    <div style={{ position: 'absolute', left: 0, right: 0, top: 420, textAlign: 'center', fontFamily: 'system-ui, sans-serif', fontWeight: 700, fontSize: 112, letterSpacing: '-0.03em', color: '#fff' }}>
      {words.map((w, i) => {
        const t = spring({ frame: frame - i * 4, fps, config: { damping: 200 } });   // 4 frames = ~67 ms stagger at 60 fps
        return <span key={i} style={{ display: 'inline-block', marginRight: 24, opacity: t, filter: `blur(${(1 - t) * 6}px)`, transform: `translateY(${(1 - t) * 24}px)` }}>{w}</span>;
      })}
    </div>
  );
};

export const Launch = () => (
  <AbsoluteFill style={{ background: STAGE }}>
    <Sequence from={0}><Line /></Sequence>
    <Sequence from={54}><Headline text="Your product here" /></Sequence>
  </AbsoluteFill>
);
