PIPES = [
    (int(x[0].strip()), [int(y.strip()) for y in x[1].split(",")])
    for x in
    [x.split("<->") for x in open("input.txt", "r").read().strip().split("\n")]
]


class Node:
    def __init__(self, val):
        self.val = val
        self.connections = []

    def add_conn(self, node):
        if node.val == self.val:
            return
        if node.val not in [x.val for x in self.connections]:
            self.connections.append(node)


class Graph:
    def __init__(self, root_val):
        self.root = Node(root_val)
        self.nodes = [self.root]

    def get_or_create_node(self, node_val):
        if node_val in [x.val for x in self.nodes]:
            return [x for x in self.nodes if x.val == node_val][0]
        n = Node(node_val)
        self.nodes.append(n)
        return n

    @staticmethod
    def walk(node, nodes=None):
        nodes = [] if nodes is None else nodes
        if node not in nodes:
            nodes.append(node)
        for n in [x for x in node.connections if x not in nodes]:
            nodes.extend([x for x in Graph.walk(n, nodes) if x not in nodes])
        return nodes


def main():
    g = Graph(PIPES[0][0])

    for n in PIPES[0][1]:
        node = g.get_or_create_node(n)
        g.root.add_conn(node)

    for k, vals in PIPES[1:]:
        k_node = g.get_or_create_node(k)
        for v in vals:
            v_node = g.get_or_create_node(v)
            k_node.add_conn(v_node)

    nodes = g.walk(g.root)
    assert len(nodes) == 306
    print(len(nodes))


if __name__ == "__main__":
    main()
