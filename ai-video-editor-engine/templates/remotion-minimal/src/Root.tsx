import { Composition } from 'remotion';
import { Launch } from './Launch';

// 60 fps, 1920x1080, 6 seconds for the test launch. Set durationInFrames to runtime * fps for real projects.
export const Root = () => (
  <Composition id="Launch" component={Launch} durationInFrames={360} fps={60} width={1920} height={1080} />
);
