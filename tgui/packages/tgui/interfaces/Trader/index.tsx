import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Box, Button, Flex, Image, NumberInput, Section, Stack } from '../../components';

const getPrice = (a) => (
  (((a.price)) ? `${a.price}⪽` : "Free")
);

const mapGoodsFromList = (act, goods, is_buying = true) => (
  goods && goods.length ? goods.map(commodity => {
    return (
      <Flex key={commodity.name} justify="space-between" align="stretch">
        <Flex.Item>
          <Button
            icon="info"
          />
          <Image
            height="32px"
            verticalAlign="middle"
            src={commodity.img}
          />
          {commodity.name}
        </Flex.Item>
        <Flex.Item>
          <Button
            content={getPrice(commodity)}
            onClick={() => act('do_haggle', { commodity_ref: commodity.ref, buying: is_buying })}
          />
          {!is_buying ? null : (
            <Box inline>
              <Button
                icon="minus"
              />
              <NumberInput
                width={4}
                value={1}
                minValue={1}
                maxValue={99}
              />
              <Button
                icon="plus"
              />
              <Button
                icon="cart-shopping"
                onClick={() => act('add_to_cart', { commodity_ref: commodity.ref })}
              />
            </Box>
          )}
        </Flex.Item>
      </Flex>);
  }) : (
    <Box>
      <i>No goods are currently available.</i>
    </Box>
  )
);

export const Trader = (_props, context) => {
  const { act, data } = useBackend(context);
  const { dialogue, shopping_cart, scanned_card, illegal } = data;
  const trader_name = data.name || "Trader";
  const mugshot = data.mugshot || [];
  const goods_sell = data.goods_sell || [];
  const goods_buy = data.goods_buy || [];
  const goods_illegal = data.goods_illegal || [];

  return (
    <Window
      title="Trader"
      width="900"
      height="600"
      fontFamily="Consolas"
      font-size="10pt">
      <Window.Content scrollable>
        <Stack vertical fill minHeight="1%" maxHeight="100%">
          <Flex
            direction="column">
            <Flex.Item mb={1}>
              <Flex direction="row">
                <Flex.Item mr={1}>
                  <Image
                    verticalAlign="middle"
                    src={mugshot}
                  />
                </Flex.Item>
                <Flex.Item grow={1} mr={1} width="54%">
                  <Section fill={1} title={trader_name}>
                    <Flex direction="column">
                      <Flex.Item justify="space-between" align="stretch">
                        {dialogue || `${trader_name} stares blankly.`}
                      </Flex.Item>
                      <Flex.Item>
                        <b>Scanned Card: </b>
                        <Button
                          disabled={scanned_card === null}
                          icon="credit-card"
                          content="None..."
                        />
                      </Flex.Item>
                      <Flex.Item>
                        <b>Available Credits: </b>750⪽
                      </Flex.Item>
                    </Flex>
                  </Section>
                </Flex.Item>
                <Flex.Item width="20%" grow={1} mr={1}>
                  <Section fill={1}>
                    <Button
                      textAlign="center"
                      width="100%"
                      icon="box"
                      content="Pick Up Order"
                    />
                  </Section>
                </Flex.Item>
              </Flex>
            </Flex.Item>
            <Flex.Item mb={1}>
              <Flex
                height="100%"
                direction="row">
                <Flex.Item mr={1} grow={1}>
                  <Section title="Selling">
                    {mapGoodsFromList(act, goods_sell)}
                  </Section>
                  <Section title="Buying">
                    {mapGoodsFromList(act, goods_buy, false)}
                  </Section>
                  {!goods_illegal.length || !illegal ? null : (
                    <Section title="Illegal Goods">
                      {mapGoodsFromList(act, goods_illegal)}
                    </Section>)}
                </Flex.Item>
                <Flex.Item mr={1} grow={1}>
                  <Section title="Cart">
                    {mapGoodsFromList(act, shopping_cart)}
                  </Section>
                </Flex.Item>
              </Flex>
            </Flex.Item>
          </Flex>
        </Stack>
      </Window.Content>
    </Window>
  );
};
