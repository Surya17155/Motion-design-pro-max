// Drop-in 3D scene for Remotion (react-three-fiber via @remotion/three).
// Rule: derive everything from the frame number. No useFrame clocks, no Date.now, no unseeded Math.random.
import { ThreeCanvas } from '@remotion/three';
import { interpolate, useCurrentFrame, useVideoConfig, Easing } from 'remotion';

export const Product3D = ({ color = '#0f1111', accent = '#FF9900' }: { color?: string; accent?: string }) => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();
  const rotY = interpolate(frame, [0, fps * 4], [0.35, -0.2], { easing: Easing.inOut(Easing.sin), extrapolateRight: 'clamp' });
  const camZ = interpolate(frame, [0, fps * 3], [9, 6], { easing: Easing.out(Easing.exp), extrapolateRight: 'clamp' });
  return (
    <ThreeCanvas width={width} height={height} camera={{ position: [0, 0.4, camZ], fov: 35 }}>
      <ambientLight intensity={0.25} />
      <directionalLight position={[3, 4, 5]} intensity={2.0} />   {/* ONE key light */}
      <mesh rotation={[0.15, rotY, 0]}>
        <boxGeometry args={[2.6, 1.6, 0.14]} />
        <meshStandardMaterial color={color} metalness={0.85} roughness={0.22} />
      </mesh>
      <mesh position={[0, 0, 0.08]} rotation={[0.15, rotY, 0]}>
        <planeGeometry args={[2.4, 1.4]} />
        <meshStandardMaterial color={accent} emissive={accent} emissiveIntensity={0.15} />
      </mesh>
    </ThreeCanvas>
  );
};
