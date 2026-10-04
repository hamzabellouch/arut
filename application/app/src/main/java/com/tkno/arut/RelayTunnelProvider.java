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

package com.tkno.arut;

import android.net.VpnService;
import android.util.Log;

import java.io.IOException;

public class RelayTunnelProvider {

    private static final String TAG = RelayTunnelProvider.class.getSimpleName();
    private static final int RETRY_DELAY_MS = 2000;

    private final VpnService vpnService;
    private final RelayTunnelListener listener;

    private RelayTunnel currentTunnel;

    public RelayTunnelProvider(VpnService vpnService, RelayTunnelListener listener) {
        this.vpnService = vpnService;
        this.listener = listener;
    }

    public synchronized Tunnel getCurrentTunnel() throws InterruptedException {
        while (currentTunnel == null) {
            try {
                currentTunnel = RelayTunnel.open(vpnService);
                currentTunnel.connect();
                listener.notifyConnected();
            } catch (IOException e) {
                Log.d(TAG, "Cannot open relay tunnel", e);
                invalidateTunnel();
                wait(RETRY_DELAY_MS);
            }
        }
        return currentTunnel;
    }

    public synchronized void invalidateTunnel(Tunnel tunnel) {
        if (currentTunnel == tunnel) {
            invalidateTunnel();
        }
    }

    public synchronized void invalidateTunnel() {
        if (currentTunnel != null) {
            listener.notifyDisconnected();
            currentTunnel.close();
            currentTunnel = null;
        }
    }
}
