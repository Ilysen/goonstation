import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const TelescienceConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    host_id,
    coord_x,
    coord_y,
    coord_z,
  } = data;
  return (
    <Window>
      <Window.Content scrollable>
        {(host_id) && (
          <Section title="Coordinates">
            <LabeledList>
              <LabeledList.Item label="X">
                {coord_x}
              </LabeledList.Item>
              <LabeledList.Item label="Y">
                {coord_y}
              </LabeledList.Item>
              <LabeledList.Item label="Z">
                {coord_z}
              </LabeledList.Item>
              <LabeledList.Item label="Button">
                <Button
                  content="Send"
                  onClick={() => act('send')} />
              </LabeledList.Item>
              <LabeledList.Item label="Button">
                <Button
                  content="Receive"
                  onClick={() => act('receive')} />
              </LabeledList.Item>
              <LabeledList.Item label="Button">
                <Button
                  content="Toggle Portal"
                  onClick={() => act('toggle_portal')} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
        {(!host_id) && (
          <Box py="20px">
            <Box align="center" fontFamily="Courier New">
              {"NO CONNECTION TO HOST"}
            </Box>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
