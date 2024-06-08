import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Button, Flex, Image, Section, Stack } from '../../components';
import { truncate } from '../../format';
import { pluralize } from '../common/stringUtils';

const getPrice = (a) => (
  a.quantity === 0 ? "Out of Stock!"
    : (((a.price)) ? `${a.price}⪽` : "Free")
);

const mapGoodsFromList = (act, scanned_card, goods, is_buying = true) => (
  goods && goods.length ? goods.map(commodity => {
    return (
      <Flex key={commodity.name} justify="space-between" align="stretch">
        <Flex.Item>
          <Button
            icon="info"
            tooltip={commodity.desc}
          />
          <Image
            height="32px"
            verticalAlign="middle"
            src={commodity.img}
          />
          {truncate(`${commodity.quantity !== -1 ? commodity.quantity + "x " : ""}${commodity.name}`, 30)}
        </Flex.Item>
        <Flex.Item>
          <Button
            tooltip="Haggle..."
            content={getPrice(commodity)}
            onClick={() => act('do_haggle', { commodity_ref: commodity.ref, buying: is_buying })}
          />
          {!is_buying ? null : (
            <>
              <Button
                icon="plus"
                onClick={() => act('add_to_cart', { commodity_ref: commodity.ref, quantity: 1 })}
              />
              <Button
                icon="cart-shopping"
                content="Add X..."
                onClick={() => act('add_to_cart', { commodity_ref: commodity.ref })}
              />
            </>
          )}
        </Flex.Item>
      </Flex>);
  }) : (
    <i>No goods are currently available.</i>
  )
);

const mapShoppingCart = (act, scanned_card, goods) => (
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
          {commodity.quantity}x {truncate(pluralize(commodity.name, commodity.quantity), 30)}
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="minus"
            onClick={() => act('add_to_cart', { commodity_ref: commodity.ref, quantity: -1 })}
          />
          <Button
            icon="plus"
            onClick={() => act('add_to_cart', { commodity_ref: commodity.ref, quantity: 1 })}
          />
          <Button
            icon="x"
            content="Remove All"
            onClick={() => act('add_to_cart', { commodity_ref: commodity.ref, quantity: -commodity.quantity })}
          />
        </Flex.Item>
      </Flex>);
  }) : (
    <i>Your shopping cart is empty.</i>
  )
);

export const Trader = (_props, context) => {
  const { act, data } = useBackend(context);
  const { dialogue, shopping_cart, scanned_card, card_credits, illegal, total_tally, include_crate } = data;
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
                      <Flex.Item mb={2}>
                        {dialogue || `${trader_name} stares blankly.`}
                      </Flex.Item>
                      <Flex.Item>
                        <b>Scanned Card: </b>
                        <Button
                          disabled={scanned_card === null}
                          icon="credit-card"
                          content={scanned_card ? scanned_card : "None"}
                          onClick={() => act('remove_card')}
                        />
                      </Flex.Item>
                      <Flex.Item>
                        <b>Available Credits: </b>{card_credits}⪽
                      </Flex.Item>
                    </Flex>
                  </Section>
                </Flex.Item>
                <Flex.Item width="20%" grow mr={1}>
                  <Section fill>
                    <Flex direction="column">
                      <Flex.Item>
                        <Button.Checkbox checked={include_crate}
                          textAlign="center"
                          width="100%"
                          content="Include Crate?"
                          onClick={() => act('toggle_crate')} />
                        <Button.Confirm
                          disabled={!shopping_cart.length}
                          textAlign="center"
                          width="100%"
                          icon="cash-register"
                          content="Complete Order"
                          onClick={() => act('complete_trade')}
                        />
                      </Flex.Item>
                      <Flex.Item mt={2} align="center">
                        {total_tally >= 0 ? <><b>Cost:</b> {total_tally}⪽</> : <><b>Profit:</b> {-total_tally}⪽</> }
                      </Flex.Item>
                    </Flex>
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
                    {mapGoodsFromList(act, scanned_card, goods_sell)}
                  </Section>
                  <Section title="Buying">
                    {mapGoodsFromList(act, scanned_card, goods_buy, false)}
                  </Section>
                  {!goods_illegal.length || !illegal ? null : (
                    <Section title="Illegal Goods" buttons={
                      <Button icon="info" tooltip="These items are only listed here because you're an antagonist. Non-antagonists can't see them!" />
                    }>
                      {mapGoodsFromList(act, scanned_card, goods_illegal)}
                    </Section>)}
                </Flex.Item>
                <Flex.Item mr={1} grow={1}>
                  <Section title="Cart" buttons={
                    <Button icon="trash" disabled={!shopping_cart.length} onClick={() => act('clear_cart')}>
                      Clear
                    </Button>
                  }>
                    <Section title="Buying">
                      {mapShoppingCart(act, scanned_card, shopping_cart)}
                    </Section>
                    <Section title="Selling">
                      <i>You aren&apos;t selling anything in this trade.</i>
                    </Section>
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
