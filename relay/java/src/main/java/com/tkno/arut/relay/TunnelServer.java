/*
 * Copyright (C) 2017 Tkno
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.tkno.arut.relay;

import java.io.IOException;
import java.net.Inet4Address;
import java.net.InetSocketAddress;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.ArrayList;
import java.util.List;

/**
 * Handle the connections from the clients.
 */
public class TunnelServer {

    private static final String TAG = TunnelServer.class.getSimpleName();

    private final List<Client> clients = new ArrayList<>();

    public TunnelServer(int port, Selector selector) throws IOException {
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        serverSocketChannel.configureBlocking(false);
        // ServerSocketChannel.bind() requires API 24
        serverSocketChannel.socket().bind(new InetSocketAddress(Inet4Address.getLoopbackAddress(), port));

        SelectionHandler socketChannelHandler = (selectionKey) -> {
            try {
                ServerSocketChannel channel = (ServerSocketChannel) selectionKey.channel();
                acceptClient(selector, channel);
            } catch (IOException e) {
                Log.e(TAG, "Cannot accept client", e);
            }
        };
        serverSocketChannel.register(selector, SelectionKey.OP_ACCEPT, socketChannelHandler);
    }

    private void acceptClient(Selector selector, ServerSocketChannel serverSocketChannel) throws IOException {
        SocketChannel socketChannel = serverSocketChannel.accept();
        socketChannel.configureBlocking(false);
        // will register the socket on the selector
        Client client = new Client(selector, socketChannel, this::removeClient);
        clients.add(client);
        Log.i(TAG, "Client #" + client.getId() + " connected");
    }

    private void removeClient(Client client) {
        clients.remove(client);
        Log.i(TAG, "Client #" + client.getId() + " disconnected");
    }

    public void cleanUp() {
        for (Client client : clients) {
            client.cleanExpiredConnections();
        }
    }
}

