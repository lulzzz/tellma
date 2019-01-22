import { Component } from '@angular/core';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { ApiService } from '~/app/data/api.service';
import { addToWorkspace } from '~/app/data/util';
import { WorkspaceService } from '~/app/data/workspace.service';
import { MasterBaseComponent } from '~/app/shared/master-base/master-base.component';

@Component({
  selector: 'b-roles-master',
  templateUrl: './roles-master.component.html',
  styleUrls: ['./roles-master.component.scss']
})
export class RolesMasterComponent extends MasterBaseComponent {

  private rolesApi = this.api.rolesApi(this.notifyDestruct$); // for intellisense

  constructor(private workspace: WorkspaceService, private api: ApiService) {
    super();
    this.rolesApi = this.api.rolesApi(this.notifyDestruct$);
  }

  public get ws() {
    return this.workspace.current.Roles;
  }

  public onActivate = (ids: (number | string)[]): Observable<any> => {
    const obs$ = this.rolesApi.activate(ids, { ReturnEntities: true }).pipe(
      tap(res => addToWorkspace(res, this.workspace))
    );

    // The master template handles any errors
    return obs$;
  }

  public onDeactivate = (ids: (number | string)[]): Observable<any> => {
    const obs$ = this.rolesApi.deactivate(ids, { ReturnEntities: true }).pipe(
      tap(res => addToWorkspace(res, this.workspace))
    );

    // The master template handles any errors
    return obs$;
  }
}
