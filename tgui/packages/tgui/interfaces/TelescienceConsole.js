import { useBackend } from '../backend';
import { Blink, Button, Icon, LabeledList, Modal, Section } from '../components';
import { Window } from '../layouts';

export const TelescienceConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    bookmarks,
    host_id,
    readout,
    can_scan,
    can_bookmark,
    coord_x,
    coord_y,
    coord_z,
  } = data;
  return (
    <Window 
      theme="ntos"
      width={350}
      height={450}>
      <Window.Content>
        {!host_id && (
          <Modal textAlign="center"
            width={25}
            height={8}
            fontSize={2}
            fontFamily="Courier"
            color="red">
            <Blink interval={500} time={500}>
              <Icon name="wifi" pr={1.5} />
            </Blink>
            NO CONNECTION
            <Button onClick={() => act('reset_connection', { hard_reset: 1 })}>Retry</Button>
          </Modal>
        )}
        <Section title={"Coordinates"}>
          <LabeledList>
            <LabeledList.Item label="X">
              <Button
                icon="angle-double-left"
                onClick={() => act('adjust_coordinate', { coordinate_key: "X", new_coordinate: coord_x - 10 })} />
              <Button
                icon="angle-left"
                onClick={() => act('adjust_coordinate', { coordinate_key: "X", new_coordinate: coord_x - 1 })} />
              <Button
                content={coord_x}
                onClick={() => act('change_coordinate', { coordinate_key: "X" })} />
              <Button
                icon="angle-right"
                onClick={() => act('adjust_coordinate', { coordinate_key: "X", new_coordinate: coord_x + 1 })} />
              <Button
                icon="angle-double-right"
                onClick={() => act('adjust_coordinate', { coordinate_key: "X", new_coordinate: coord_x + 10 })} />
            </LabeledList.Item>
            <LabeledList.Item label="Y">
              <Button
                icon="angle-double-left"
                onClick={() => act('adjust_coordinate', { coordinate_key: "Y", new_coordinate: coord_y - 10 })} />
              <Button
                icon="angle-left"
                onClick={() => act('adjust_coordinate', { coordinate_key: "Y", new_coordinate: coord_y - 1 })} />
              <Button
                content={coord_y}
                onClick={() => act('change_coordinate', { coordinate_key: "Y" })} />
              <Button
                icon="angle-right"
                onClick={() => act('adjust_coordinate', { coordinate_key: "Y", new_coordinate: coord_y + 1 })} />
              <Button
                icon="angle-double-right"
                onClick={() => act('adjust_coordinate', { coordinate_key: "Y", new_coordinate: coord_y + 10 })} />
            </LabeledList.Item>
            <LabeledList.Item label="Z">
              <Button
                icon="angle-double-left"
                onClick={() => act('adjust_coordinate', { coordinate_key: "Z", new_coordinate: coord_z - 10 })} />
              <Button
                icon="angle-left"
                onClick={() => act('adjust_coordinate', { coordinate_key: "Z", new_coordinate: coord_z - 1 })} />
              <Button
                content={coord_z}
                onClick={() => act('change_coordinate', { coordinate_key: "Z" })} />
              <Button
                icon="angle-right"
                onClick={() => act('adjust_coordinate', { coordinate_key: "Z", new_coordinate: coord_z + 1 })} />
              <Button
                icon="angle-double-right"
                onClick={() => act('adjust_coordinate', { coordinate_key: "Z", new_coordinate: coord_z + 10 })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Controls"
          buttons={
            <Button
              textAlign="center"
              icon="rss"
              onClick={() => act('scan')}>
              Scan
            </Button>
          }>
          <Button
            textAlign="center"
            icon="sign-out-alt"
            onClick={() => act('send')}>
            Send
          </Button>
          <Button
            textAlign="center"
            icon="sign-in-alt"
            onClick={() => act('receive')}>
            Receive
          </Button>
          <Button
            textAlign="center"
            icon="satellite-dish"
            onClick={() => act('toggle_portal')}>
            Toggle Portal
          </Button>
        </Section>
        <Section title="Output">
          {readout}
        </Section>
        {!!data.can_bookmark && (
          <Section title="Bookmarks"
            scrollable
            buttons={(
              <Button icon="plus"
                onClick={() => act('add_bookmark')} />
            )}
          >
            {!data.bookmarks.length && ("No active bookmarks.")}
            {!!data.bookmarks.length && (
              <LabeledList>
                {data.bookmarks.map((currentBookmark) => (
                  <LabeledList.Item 
                    label={currentBookmark.name} 
                    key={currentBookmark.name}
                    buttons={(
                      <>
                        <Button
                          icon="upload"
                          onClick={() => act('restore_bookmark', { ref: currentBookmark.ref })}>Restore
                        </Button>
                  
                        <Button 
                          icon="trash-alt"
                          onClick={() => act('delete_bookmark', { ref: currentBookmark.ref })}>Delete
                        </Button>  
                      </>
                    )}
                  >
                    ({currentBookmark.x}, {currentBookmark.y}, {currentBookmark.z})
                  </LabeledList.Item>
                ))}
              </LabeledList>)}
          </Section>
        )}
        <Button onClick={() => act('reset_connection', { hard_reset: 0 })}>Reset Connection</Button>
      </Window.Content>
    </Window>
  );
};
